-- OmegaT Builder Database Schema
-- Ledger for PoAI events and blocks

CREATE TABLE IF NOT EXISTS blocks (
  id TEXT PRIMARY KEY,
  proof TEXT NOT NULL,
  seed TEXT NOT NULL,
  snapshot TEXT NOT NULL,
  timestamp INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY,
  uid TEXT NOT NULL,
  event TEXT NOT NULL,
  state_hash TEXT,
  timestamp INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_blocks_timestamp ON blocks(timestamp);
CREATE INDEX IF NOT EXISTS idx_transactions_timestamp ON transactions(timestamp);
CREATE INDEX IF NOT EXISTS idx_transactions_uid ON transactions(uid);