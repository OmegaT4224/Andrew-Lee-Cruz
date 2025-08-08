/**
 * Database Operations Module
 * Handles D1 database interactions for quantum data
 */

export async function storeQuantumExecution(db: D1Database, violetState: any): Promise<void> {
  const { 
    violet_sequence_id, 
    circuit_data, 
    quantum_result, 
    task_tree,
    timestamp 
  } = violetState;

  await db.prepare(`
    INSERT INTO quantum_executions (
      sequence_id, circuit_qasm, statevector_json, task_tree_json,
      measurement_outcomes, backend, execution_timestamp
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
  `).bind(
    violet_sequence_id,
    circuit_data?.qasm || '',
    JSON.stringify(quantum_result?.statevector || {}),
    JSON.stringify(task_tree || {}),
    JSON.stringify(quantum_result?.statevector?.measurement_outcomes || {}),
    quantum_result?.backend || 'unknown',
    Math.floor(timestamp || Date.now() / 1000)
  ).run();
}

export async function getQuantumHistory(db: D1Database): Promise<any[]> {
  const result = await db.prepare(`
    SELECT sequence_id, backend, execution_timestamp, created_at
    FROM quantum_executions 
    ORDER BY execution_timestamp DESC 
    LIMIT 50
  `).all();

  return result.results || [];
}

export async function storeReflectChainLog(db: D1Database, logEntry: any): Promise<void> {
  const { uid, type, signature, timestamp, nonce, ...payload } = logEntry;

  await db.prepare(`
    INSERT INTO reflect_chain_logs (
      uid, entry_type, signature, timestamp, nonce, payload_json
    ) VALUES (?, ?, ?, ?, ?, ?)
  `).bind(
    uid || 'ALC-ROOT-1010-1111-XCOV∞',
    type || 'unknown',
    signature || '',
    timestamp || Date.now(),
    nonce || 0,
    JSON.stringify(payload)
  ).run();
}