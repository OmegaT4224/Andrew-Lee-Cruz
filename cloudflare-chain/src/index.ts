/**
 * VIOLET-AF Cloudflare Worker Chain Backend
 * 
 * Serverless blockchain backend with D1 database and R2 storage integration
 * 
 * Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
 * License: UCL-∞
 */

export interface Env {
  cm_chain_db: D1Database;
  'cm-ledger': R2Bucket;
  CREATOR_UID: string;
  CREATOR_EMAIL: string;
  POAI_API_KEY: string;
}

interface PoAISubmission {
  uid: string;
  deviceId: string;
  digest: string;
  signature: string;
  attestationToken?: string;
  timestamp: number;
}

interface BlockData {
  height: number;
  previousHash: string;
  timestamp: number;
  poaiDigest: string;
  transactions: any[];
  merkleRoot: string;
  creator: string;
}

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
  'Content-Type': 'application/json'
};

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 200, headers: CORS_HEADERS });
    }

    try {
      switch (url.pathname) {
        case '/poai/submit':
          return await handlePoAISubmit(request, env);
        case '/poai/status':
          return await handleStatus(request, env);
        case '/poai/blocks':
          return await handleBlocks(request, env);
        case '/health':
          return await handleHealth(request, env);
        default:
          return new Response('Not Found', { status: 404, headers: CORS_HEADERS });
      }
    } catch (error) {
      console.error('Worker error:', error);
      return new Response(JSON.stringify({ 
        error: 'Internal server error',
        message: error.message 
      }), { 
        status: 500, 
        headers: CORS_HEADERS 
      });
    }
  }
};

async function handlePoAISubmit(request: Request, env: Env): Promise<Response> {
  if (request.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: CORS_HEADERS });
  }

  // Rate limiting check
  const clientIP = request.headers.get('CF-Connecting-IP') || 'unknown';
  const rateLimitKey = `rate_limit:${clientIP}`;
  
  // Simple rate limiting (in production, use Durable Objects or external service)
  const rateLimitCheck = await checkRateLimit(rateLimitKey, env);
  if (!rateLimitCheck.allowed) {
    return new Response(JSON.stringify({
      error: 'Rate limit exceeded',
      retryAfter: rateLimitCheck.retryAfter
    }), { status: 429, headers: CORS_HEADERS });
  }

  try {
    const submission: PoAISubmission = await request.json();
    
    // Validate API key (simple check - in production use more sophisticated auth)
    const apiKey = request.headers.get('X-API-Key');
    if (apiKey !== env.POAI_API_KEY) {
      return new Response(JSON.stringify({ error: 'Invalid API key' }), { 
        status: 401, 
        headers: CORS_HEADERS 
      });
    }

    // Validate submission format
    if (!isValidSubmission(submission, env)) {
      return new Response(JSON.stringify({ error: 'Invalid submission format' }), { 
        status: 400, 
        headers: CORS_HEADERS 
      });
    }

    // Verify attestation token if provided
    if (submission.attestationToken) {
      const attestationValid = await verifyAttestationToken(submission.attestationToken);
      if (!attestationValid) {
        return new Response(JSON.stringify({ error: 'Invalid attestation token' }), { 
          status: 400, 
          headers: CORS_HEADERS 
        });
      }
    }

    // Store submission in D1 database
    const submissionId = await storeSubmission(submission, env);
    
    // Process the PoAI digest and potentially create a new block
    const blockResult = await processPoAIDigest(submission, env);

    return new Response(JSON.stringify({
      success: true,
      submissionId,
      blockHeight: blockResult.blockHeight,
      digest: submission.digest,
      timestamp: submission.timestamp
    }), { 
      status: 200, 
      headers: CORS_HEADERS 
    });

  } catch (error) {
    console.error('Error processing PoAI submission:', error);
    return new Response(JSON.stringify({ 
      error: 'Failed to process submission',
      message: error.message 
    }), { 
      status: 500, 
      headers: CORS_HEADERS 
    });
  }
}

async function handleStatus(request: Request, env: Env): Promise<Response> {
  try {
    // Get current chain status
    const headInfo = await getChainHead(env);
    const recentDigests = await getRecentDigests(env, 5);
    const pendingSubmissions = await getPendingSubmissions(env);

    const status = {
      chainHead: {
        height: headInfo.height,
        hash: headInfo.hash,
        timestamp: headInfo.timestamp,
        poaiDigest: headInfo.poaiDigest
      },
      recentDigests,
      pendingSubmissions: pendingSubmissions.length,
      network: {
        name: 'VIOLET-AF PoAI Chain',
        version: '1.0.0',
        creator: env.CREATOR_UID
      },
      timestamp: Date.now()
    };

    return new Response(JSON.stringify(status), { 
      status: 200, 
      headers: CORS_HEADERS 
    });
  } catch (error) {
    console.error('Error getting chain status:', error);
    return new Response(JSON.stringify({ 
      error: 'Failed to get status',
      message: error.message 
    }), { 
      status: 500, 
      headers: CORS_HEADERS 
    });
  }
}

async function handleBlocks(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const height = url.searchParams.get('height');
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '10'), 100);

  try {
    if (height) {
      // Get specific block
      const block = await getBlock(parseInt(height), env);
      if (!block) {
        return new Response(JSON.stringify({ error: 'Block not found' }), { 
          status: 404, 
          headers: CORS_HEADERS 
        });
      }
      return new Response(JSON.stringify(block), { 
        status: 200, 
        headers: CORS_HEADERS 
      });
    } else {
      // Get recent blocks
      const blocks = await getRecentBlocks(limit, env);
      return new Response(JSON.stringify({ blocks }), { 
        status: 200, 
        headers: CORS_HEADERS 
      });
    }
  } catch (error) {
    console.error('Error getting blocks:', error);
    return new Response(JSON.stringify({ 
      error: 'Failed to get blocks',
      message: error.message 
    }), { 
      status: 500, 
      headers: CORS_HEADERS 
    });
  }
}

async function handleHealth(request: Request, env: Env): Promise<Response> {
  try {
    // Basic health check
    const dbCheck = await env.cm_chain_db.prepare('SELECT 1').first();
    
    return new Response(JSON.stringify({
      status: 'healthy',
      timestamp: Date.now(),
      services: {
        database: !!dbCheck,
        storage: true, // R2 is generally available
        worker: true
      }
    }), { 
      status: 200, 
      headers: CORS_HEADERS 
    });
  } catch (error) {
    return new Response(JSON.stringify({
      status: 'unhealthy',
      error: error.message,
      timestamp: Date.now()
    }), { 
      status: 503, 
      headers: CORS_HEADERS 
    });
  }
}

// Helper functions

function isValidSubmission(submission: PoAISubmission, env: Env): boolean {
  return !!(
    submission.uid &&
    submission.deviceId &&
    submission.digest &&
    submission.signature &&
    submission.timestamp &&
    submission.uid === env.CREATOR_UID
  );
}

async function verifyAttestationToken(token: string): Promise<boolean> {
  // In production, verify Play Integrity token with Google's API
  // For now, basic validation
  return token.length > 0;
}

async function storeSubmission(submission: PoAISubmission, env: Env): Promise<string> {
  const submissionId = crypto.randomUUID();
  
  await env.cm_chain_db
    .prepare(`
      INSERT INTO submissions (id, uid, device_id, digest, signature, attestation_token, timestamp)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `)
    .bind(
      submissionId,
      submission.uid,
      submission.deviceId,
      submission.digest,
      submission.signature,
      submission.attestationToken || null,
      submission.timestamp
    )
    .run();

  return submissionId;
}

async function processPoAIDigest(submission: PoAISubmission, env: Env): Promise<{ blockHeight: number }> {
  // Get current head
  const headInfo = await getChainHead(env);
  const newHeight = headInfo.height + 1;

  // Create new block
  const blockData: BlockData = {
    height: newHeight,
    previousHash: headInfo.hash,
    timestamp: Date.now(),
    poaiDigest: submission.digest,
    transactions: [], // Would include actual transactions
    merkleRoot: await calculateMerkleRoot([submission]),
    creator: env.CREATOR_UID
  };

  // Store block in R2
  const blockKey = `blocks/${newHeight}.json`;
  await env['cm-ledger'].put(blockKey, JSON.stringify(blockData));

  // Update blocks table in D1
  const blockHash = await calculateBlockHash(blockData);
  await env.cm_chain_db
    .prepare(`
      INSERT INTO blocks (height, hash, previous_hash, poai_digest, merkle_root, timestamp, r2_key)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `)
    .bind(
      newHeight,
      blockHash,
      blockData.previousHash,
      blockData.poaiDigest,
      blockData.merkleRoot,
      blockData.timestamp,
      blockKey
    )
    .run();

  return { blockHeight: newHeight };
}

async function getChainHead(env: Env): Promise<{
  height: number;
  hash: string;
  timestamp: number;
  poaiDigest: string;
}> {
  const result = await env.cm_chain_db
    .prepare('SELECT * FROM blocks ORDER BY height DESC LIMIT 1')
    .first();

  if (!result) {
    // Genesis block
    return {
      height: 0,
      hash: '0x0000000000000000000000000000000000000000000000000000000000000000',
      timestamp: Date.now(),
      poaiDigest: ''
    };
  }

  return {
    height: result.height as number,
    hash: result.hash as string,
    timestamp: result.timestamp as number,
    poaiDigest: result.poai_digest as string
  };
}

async function getRecentDigests(env: Env, limit: number): Promise<Array<{
  digest: string;
  height: number;
  timestamp: number;
}>> {
  const results = await env.cm_chain_db
    .prepare('SELECT poai_digest, height, timestamp FROM blocks ORDER BY height DESC LIMIT ?')
    .bind(limit)
    .all();

  return results.results.map(row => ({
    digest: row.poai_digest as string,
    height: row.height as number,
    timestamp: row.timestamp as number
  }));
}

async function getPendingSubmissions(env: Env): Promise<any[]> {
  const results = await env.cm_chain_db
    .prepare('SELECT * FROM submissions WHERE processed = 0 ORDER BY timestamp DESC')
    .all();

  return results.results;
}

async function getBlock(height: number, env: Env): Promise<any> {
  const result = await env.cm_chain_db
    .prepare('SELECT * FROM blocks WHERE height = ?')
    .bind(height)
    .first();

  if (!result) return null;

  // Get full block data from R2
  const blockData = await env['cm-ledger'].get(result.r2_key as string);
  if (blockData) {
    return JSON.parse(await blockData.text());
  }

  return result;
}

async function getRecentBlocks(limit: number, env: Env): Promise<any[]> {
  const results = await env.cm_chain_db
    .prepare('SELECT * FROM blocks ORDER BY height DESC LIMIT ?')
    .bind(limit)
    .all();

  return results.results;
}

async function calculateMerkleRoot(data: any[]): Promise<string> {
  // Simple hash for merkle root calculation
  const combined = JSON.stringify(data);
  const encoder = new TextEncoder();
  const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(combined));
  return Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

async function calculateBlockHash(blockData: BlockData): Promise<string> {
  const blockString = JSON.stringify(blockData);
  const encoder = new TextEncoder();
  const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(blockString));
  return Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

async function checkRateLimit(key: string, env: Env): Promise<{ allowed: boolean; retryAfter?: number }> {
  // Simple rate limiting - in production use Durable Objects or KV with TTL
  // For now, allow all requests (implement proper rate limiting in production)
  return { allowed: true };
}