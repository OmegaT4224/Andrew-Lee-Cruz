-- VIOLET-AF Quantum Database Schema
-- UID: ALC-ROOT-1010-1111-XCOV∞
-- Contact: allcatch37@gmail.com

CREATE TABLE quantum_executions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sequence_id TEXT UNIQUE NOT NULL,
    uid TEXT NOT NULL DEFAULT 'ALC-ROOT-1010-1111-XCOV∞',
    creator_email TEXT NOT NULL DEFAULT 'allcatch37@gmail.com',
    circuit_qasm TEXT NOT NULL,
    statevector_json TEXT NOT NULL,
    task_tree_json TEXT NOT NULL,
    measurement_outcomes TEXT NOT NULL,
    backend TEXT NOT NULL,
    execution_timestamp INTEGER NOT NULL,
    created_at INTEGER DEFAULT (unixepoch())
);

CREATE TABLE reflect_chain_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uid TEXT NOT NULL DEFAULT 'ALC-ROOT-1010-1111-XCOV∞',
    entry_type TEXT NOT NULL,
    signature TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    nonce INTEGER NOT NULL,
    payload_json TEXT NOT NULL,
    created_at INTEGER DEFAULT (unixepoch())
);

CREATE TABLE access_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint TEXT NOT NULL,
    method TEXT NOT NULL,
    user_agent TEXT,
    cf_connecting_ip TEXT,
    cf_country TEXT,
    timestamp INTEGER NOT NULL,
    response_status INTEGER,
    created_at INTEGER DEFAULT (unixepoch())
);

CREATE INDEX idx_quantum_sequence_id ON quantum_executions(sequence_id);
CREATE INDEX idx_quantum_uid ON quantum_executions(uid);
CREATE INDEX idx_reflect_uid ON reflect_chain_logs(uid);
CREATE INDEX idx_reflect_type ON reflect_chain_logs(entry_type);
CREATE INDEX idx_access_endpoint ON access_logs(endpoint);
CREATE INDEX idx_access_timestamp ON access_logs(timestamp);