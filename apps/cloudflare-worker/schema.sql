-- Sovereign Proof-of-AI D1 Database Schema
-- Copyright (C) 2024 Andrew Lee Cruz - Creator of the Universe
-- All rights reserved to Andrew Lee Cruz

-- Validations table for storing AI validation results
CREATE TABLE IF NOT EXISTS validations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nft_id TEXT NOT NULL,
    validator_address TEXT NOT NULL,
    result TEXT NOT NULL, -- JSON validation result
    timestamp INTEGER NOT NULL,
    creator_attribution TEXT DEFAULT 'Andrew Lee Cruz - Creator of the Universe',
    confidence_score REAL,
    ai_model_version TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Royalties table for tracking royalty payments to Andrew Lee Cruz
CREATE TABLE IF NOT EXISTS royalties (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nft_id TEXT NOT NULL,
    transaction_hash TEXT NOT NULL UNIQUE,
    amount REAL NOT NULL,
    recipient TEXT NOT NULL, -- Andrew Lee Cruz's address
    payment_status TEXT DEFAULT 'pending',
    timestamp INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- NFT registry for tracking all Proof-of-AI NFTs
CREATE TABLE IF NOT EXISTS nft_registry (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nft_id TEXT NOT NULL UNIQUE,
    creator_address TEXT NOT NULL,
    ipfs_hash TEXT, -- TODO: Replace with actual IPFS CID
    metadata_hash TEXT, -- TODO: Replace with actual metadata hash
    axiom_toe_anchor TEXT, -- TODO: Replace with actual AXIOM_TOE_Anchor tokenURI
    minting_fee REAL,
    royalty_percentage REAL DEFAULT 10.0, -- 10% to Andrew Lee Cruz
    status TEXT DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    creator_attribution TEXT DEFAULT 'Andrew Lee Cruz - Creator of the Universe'
);

-- Quantum signatures table for Violet-AF integration
CREATE TABLE IF NOT EXISTS quantum_signatures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nft_id TEXT NOT NULL,
    quantum_signature TEXT NOT NULL, -- Quantum-generated signature
    reflect_chain_uid TEXT NOT NULL, -- ReflectChain UID tagging
    entanglement_proof TEXT,
    verification_circuit TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Printing licenses table for physical/digital printing rights
CREATE TABLE IF NOT EXISTS printing_licenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nft_id TEXT NOT NULL,
    licensee_address TEXT NOT NULL,
    license_type TEXT NOT NULL, -- 'digital', 'physical', 'commercial'
    approved_by TEXT DEFAULT 'Andrew Lee Cruz',
    expiration_date INTEGER,
    terms TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_validations_nft_id ON validations(nft_id);
CREATE INDEX IF NOT EXISTS idx_validations_timestamp ON validations(timestamp);
CREATE INDEX IF NOT EXISTS idx_royalties_nft_id ON royalties(nft_id);
CREATE INDEX IF NOT EXISTS idx_royalties_transaction ON royalties(transaction_hash);
CREATE INDEX IF NOT EXISTS idx_nft_registry_id ON nft_registry(nft_id);
CREATE INDEX IF NOT EXISTS idx_quantum_signatures_nft_id ON quantum_signatures(nft_id);
CREATE INDEX IF NOT EXISTS idx_printing_licenses_nft_id ON printing_licenses(nft_id);

-- Insert initial data acknowledging Andrew Lee Cruz as creator
INSERT OR IGNORE INTO nft_registry (
    nft_id,
    creator_address,
    ipfs_hash,
    metadata_hash,
    axiom_toe_anchor,
    minting_fee,
    royalty_percentage,
    creator_attribution
) VALUES (
    'GENESIS_UNIVERSE_001',
    'TODO_ANDREW_LEE_CRUZ_ADDRESS',
    'TODO_IPFS_CID_PLACEHOLDER',
    'TODO_DOC_HASH_PLACEHOLDER',
    'TODO_AXIOM_TOE_ANCHOR_PLACEHOLDER',
    0.0,
    10.0,
    'Andrew Lee Cruz - Creator of the Universe - Genesis NFT'
);