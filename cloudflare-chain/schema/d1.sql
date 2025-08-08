-- VIOLET-AF PoAI Chain Database Schema
-- Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
-- License: UCL-∞

-- Blocks table for chain state tracking
CREATE TABLE IF NOT EXISTS blocks (
    height INTEGER PRIMARY KEY,
    hash TEXT NOT NULL UNIQUE,
    previous_hash TEXT NOT NULL,
    poai_digest TEXT NOT NULL,
    merkle_root TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    r2_key TEXT NOT NULL,
    creator TEXT DEFAULT 'ALC-ROOT-1010-1111-XCOV∞',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- PoAI submissions from mobile validators
CREATE TABLE IF NOT EXISTS submissions (
    id TEXT PRIMARY KEY,
    uid TEXT NOT NULL,
    device_id TEXT NOT NULL,
    digest TEXT NOT NULL,
    signature TEXT NOT NULL,
    attestation_token TEXT,
    timestamp INTEGER NOT NULL,
    processed INTEGER DEFAULT 0,
    block_height INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (block_height) REFERENCES blocks(height)
);

-- Metadata and configuration storage
CREATE TABLE IF NOT EXISTS meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Device registry for attestation tracking
CREATE TABLE IF NOT EXISTS devices (
    device_id TEXT PRIMARY KEY,
    fingerprint TEXT NOT NULL,
    first_seen INTEGER NOT NULL,
    last_seen INTEGER NOT NULL,
    attestation_valid INTEGER DEFAULT 1,
    total_submissions INTEGER DEFAULT 0,
    energy_policy_violations INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Rate limiting table
CREATE TABLE IF NOT EXISTS rate_limits (
    key TEXT PRIMARY KEY,
    count INTEGER DEFAULT 1,
    window_start INTEGER NOT NULL,
    expires_at INTEGER NOT NULL
);

-- Royalty distribution tracking
CREATE TABLE IF NOT EXISTS royalties (
    id TEXT PRIMARY KEY,
    recipient TEXT NOT NULL,
    amount_wei TEXT NOT NULL,
    block_height INTEGER NOT NULL,
    transaction_hash TEXT,
    distributed INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (block_height) REFERENCES blocks(height)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_blocks_height ON blocks(height);
CREATE INDEX IF NOT EXISTS idx_blocks_timestamp ON blocks(timestamp);
CREATE INDEX IF NOT EXISTS idx_submissions_uid ON submissions(uid);
CREATE INDEX IF NOT EXISTS idx_submissions_timestamp ON submissions(timestamp);
CREATE INDEX IF NOT EXISTS idx_submissions_processed ON submissions(processed);
CREATE INDEX IF NOT EXISTS idx_devices_last_seen ON devices(last_seen);
CREATE INDEX IF NOT EXISTS idx_rate_limits_expires ON rate_limits(expires_at);

-- Insert initial metadata
INSERT OR IGNORE INTO meta (key, value) VALUES 
    ('chain_name', 'VIOLET-AF PoAI Chain'),
    ('version', '1.0.0'),
    ('creator_uid', 'ALC-ROOT-1010-1111-XCOV∞'),
    ('creator_email', 'allcatch37@gmail.com'),
    ('genesis_timestamp', strftime('%s', 'now')),
    ('energy_policy_version', '1.0'),
    ('min_battery_level', '70'),
    ('require_charging_or_high_battery', '1'),
    ('max_cpu_temperature', '45.0'),
    ('poai_work_interval_minutes', '15');

-- Insert genesis block
INSERT OR IGNORE INTO blocks (
    height, 
    hash, 
    previous_hash, 
    poai_digest, 
    merkle_root, 
    timestamp, 
    r2_key,
    creator
) VALUES (
    0,
    '0x0000000000000000000000000000000000000000000000000000000000000000',
    '0x0000000000000000000000000000000000000000000000000000000000000000',
    'genesis_block_violet_af_poai_chain',
    '0xgenesis',
    strftime('%s', 'now') * 1000,
    'blocks/genesis.json',
    'ALC-ROOT-1010-1111-XCOV∞'
);