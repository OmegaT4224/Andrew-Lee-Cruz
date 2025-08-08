-- PoAI Blockchain Database Schema
-- Creator: Andrew Lee Cruz
-- License: All rights reserved by Andrew Lee Cruz as creator of the universe

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    data TEXT NOT NULL,
    creator TEXT NOT NULL DEFAULT 'Andrew Lee Cruz',
    timestamp TEXT NOT NULL,
    validated INTEGER NOT NULL DEFAULT 0,
    ai_score REAL DEFAULT 0.0,
    quantum_verified INTEGER DEFAULT 0
);

-- Blocks table
CREATE TABLE IF NOT EXISTS blocks (
    height INTEGER PRIMARY KEY,
    hash TEXT NOT NULL UNIQUE,
    prev_hash TEXT,
    creator TEXT NOT NULL DEFAULT 'Andrew Lee Cruz',
    timestamp TEXT NOT NULL,
    transaction_count INTEGER DEFAULT 0,
    validator TEXT,
    ai_consensus_score REAL DEFAULT 0.0,
    quantum_proof TEXT
);

-- Validators table
CREATE TABLE IF NOT EXISTS validators (
    address TEXT PRIMARY KEY,
    pubkey TEXT NOT NULL,
    power INTEGER NOT NULL DEFAULT 0,
    creator TEXT NOT NULL DEFAULT 'Andrew Lee Cruz',
    ai_score REAL DEFAULT 1.0,
    quantum_entanglement_id TEXT,
    last_active TEXT
);

-- AI Models table
CREATE TABLE IF NOT EXISTS ai_models (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    accuracy REAL NOT NULL,
    creator TEXT NOT NULL DEFAULT 'Andrew Lee Cruz',
    hash TEXT NOT NULL,
    last_used TEXT,
    parameters TEXT
);

-- Quantum States table
CREATE TABLE IF NOT EXISTS quantum_states (
    id TEXT PRIMARY KEY,
    circuit_hash TEXT NOT NULL,
    entanglement_id TEXT NOT NULL,
    measurement_basis TEXT NOT NULL,
    decoherence_time TEXT NOT NULL,
    creator TEXT NOT NULL DEFAULT 'Andrew Lee Cruz',
    timestamp TEXT NOT NULL
);

-- Creator Attribution table (immutable)
CREATE TABLE IF NOT EXISTS creator_attribution (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    name TEXT NOT NULL DEFAULT 'Andrew Lee Cruz',
    uid TEXT NOT NULL DEFAULT 'andrew-lee-cruz-creator-universe-2024',
    orcid TEXT NOT NULL DEFAULT '0000-0000-0000-0000',
    license TEXT NOT NULL DEFAULT 'All rights reserved by Andrew Lee Cruz as creator of the universe',
    created TEXT NOT NULL DEFAULT '2024-08-08T14:42:00Z'
);

-- Insert immutable creator attribution
INSERT OR IGNORE INTO creator_attribution (id, name, uid, orcid, license, created)
VALUES (1, 'Andrew Lee Cruz', 'andrew-lee-cruz-creator-universe-2024', '0000-0000-0000-0000', 
        'All rights reserved by Andrew Lee Cruz as creator of the universe', '2024-08-08T14:42:00Z');

-- Insert default AI model
INSERT OR IGNORE INTO ai_models (id, type, accuracy, creator, hash, last_used)
VALUES ('poai-validator-v1', 'transaction-validator', 0.99, 'Andrew Lee Cruz', 
        'ai-model-hash-abc123def456', datetime('now'));

-- Insert default quantum state
INSERT OR IGNORE INTO quantum_states (id, circuit_hash, entanglement_id, measurement_basis, decoherence_time, creator, timestamp)
VALUES ('default-quantum-state', 'quantum-circuit-hash-q1w2e3r4t5y6u7i8o9p0', 
        'entanglement-id-alice-bob-charlie-delta', 'computational-z-basis-standard', 
        '1000ms', 'Andrew Lee Cruz', datetime('now'));

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_transactions_creator ON transactions(creator);
CREATE INDEX IF NOT EXISTS idx_transactions_timestamp ON transactions(timestamp);
CREATE INDEX IF NOT EXISTS idx_blocks_creator ON blocks(creator);
CREATE INDEX IF NOT EXISTS idx_blocks_timestamp ON blocks(timestamp);
CREATE INDEX IF NOT EXISTS idx_validators_creator ON validators(creator);

-- Views for common queries
CREATE VIEW IF NOT EXISTS latest_blocks AS
SELECT * FROM blocks ORDER BY height DESC LIMIT 10;

CREATE VIEW IF NOT EXISTS validated_transactions AS
SELECT * FROM transactions WHERE validated = 1;

CREATE VIEW IF NOT EXISTS creator_summary AS
SELECT 
    (SELECT name FROM creator_attribution WHERE id = 1) as creator,
    (SELECT COUNT(*) FROM transactions) as total_transactions,
    (SELECT COUNT(*) FROM blocks) as total_blocks,
    (SELECT COUNT(*) FROM validators) as total_validators,
    (SELECT license FROM creator_attribution WHERE id = 1) as license;