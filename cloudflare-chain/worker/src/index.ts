/**
 * VIOLET-AF Quantum Worker - Main Entry Point
 * UID: ALC-ROOT-1010-1111-XCOV∞
 * Contact: allcatch37@gmail.com
 */

import { Router } from 'itty-router';
import { handleQuantumStatus } from './ai';
import { storeQuantumExecution, getQuantumHistory } from './db';
import { uploadQuantumState, getQuantumState } from './r2';

export interface Env {
  DB: D1Database;
  QUANTUM_STORAGE: R2Bucket;
  CREATOR_UID: string;
  CREATOR_EMAIL: string;
  ENVIRONMENT: string;
}

const router = Router();

// Health check endpoint
router.get('/', () => {
  return new Response(JSON.stringify({
    service: 'VIOLET-AF Quantum Worker',
    uid: 'ALC-ROOT-1010-1111-XCOV∞',
    contact: 'allcatch37@gmail.com',
    status: 'healthy',
    timestamp: Date.now()
  }), {
    headers: { 'Content-Type': 'application/json' }
  });
});

// Quantum status endpoint - serves quantum results
router.get('/status', async (request: Request, env: Env) => {
  try {
    const response = await handleQuantumStatus(env.DB);
    
    // Log access
    await logAccess(env.DB, '/status', 'GET', request, 200);
    
    return response;
  } catch (error) {
    await logAccess(env.DB, '/status', 'GET', request, 500);
    return new Response(JSON.stringify({
      error: 'Internal server error',
      uid: env.CREATOR_UID
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});

// Store quantum execution results
router.post('/quantum/store', async (request: Request, env: Env) => {
  try {
    // Verify creator authorization
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.includes(env.CREATOR_EMAIL)) {
      return new Response(JSON.stringify({
        error: 'Unauthorized - creator access required',
        required_contact: env.CREATOR_EMAIL
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const violetState = await request.json() as any;
    
    // Store in D1 database
    await storeQuantumExecution(env.DB, violetState);
    
    // Store full state in R2
    await uploadQuantumState(env.QUANTUM_STORAGE, violetState);
    
    await logAccess(env.DB, '/quantum/store', 'POST', request, 200);
    
    return new Response(JSON.stringify({
      success: true,
      sequence_id: violetState.violet_sequence_id,
      uid: env.CREATOR_UID
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
    
  } catch (error) {
    await logAccess(env.DB, '/quantum/store', 'POST', request, 500);
    return new Response(JSON.stringify({
      error: 'Failed to store quantum execution',
      uid: env.CREATOR_UID
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});

// Get quantum execution history
router.get('/quantum/history', async (request: Request, env: Env) => {
  try {
    const history = await getQuantumHistory(env.DB);
    
    await logAccess(env.DB, '/quantum/history', 'GET', request, 200);
    
    return new Response(JSON.stringify({
      history,
      uid: env.CREATOR_UID,
      count: history.length
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
    
  } catch (error) {
    await logAccess(env.DB, '/quantum/history', 'GET', request, 500);
    return new Response(JSON.stringify({
      error: 'Failed to retrieve history',
      uid: env.CREATOR_UID
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});

// Admin routes - restricted to creator email
router.get('/admin/*', async (request: Request, env: Env) => {
  // This will be protected by Cloudflare Access
  return new Response(JSON.stringify({
    message: 'Admin access restricted to creator',
    creator: env.CREATOR_EMAIL,
    uid: env.CREATOR_UID
  }), {
    headers: { 'Content-Type': 'application/json' }
  });
});

// Catch-all 404
router.all('*', async (request: Request, env: Env) => {
  await logAccess(env.DB, request.url, request.method, request, 404);
  return new Response(JSON.stringify({
    error: 'Not Found',
    uid: env.CREATOR_UID
  }), { 
    status: 404,
    headers: { 'Content-Type': 'application/json' }
  });
});

async function logAccess(
  db: D1Database, 
  endpoint: string, 
  method: string, 
  request: Request, 
  status: number
) {
  try {
    await db.prepare(`
      INSERT INTO access_logs (endpoint, method, user_agent, cf_connecting_ip, cf_country, timestamp, response_status)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `).bind(
      endpoint,
      method,
      request.headers.get('User-Agent') || '',
      request.headers.get('CF-Connecting-IP') || '',
      request.headers.get('CF-IPCountry') || '',
      Date.now(),
      status
    ).run();
  } catch (error) {
    console.error('Failed to log access:', error);
  }
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    return router.handle(request, env, ctx);
  },
};