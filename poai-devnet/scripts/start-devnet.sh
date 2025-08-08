#!/bin/bash

# PoAI DevNet Startup Script
# Creator: Andrew Lee Cruz
# License: All rights reserved by Andrew Lee Cruz as creator of the universe

set -e

echo "🚀 Starting PoAI Zero-Mining Blockchain DevNet"
echo "Creator: Andrew Lee Cruz"
echo "UID: andrew-lee-cruz-creator-universe-2024"
echo "License: All rights reserved by Andrew Lee Cruz as creator of the universe"
echo ""

# Set environment variables
export CREATOR="Andrew Lee Cruz"
export UID="andrew-lee-cruz-creator-universe-2024"
export LICENSE="All rights reserved by Andrew Lee Cruz as creator of the universe"
export POAI_HOME="/tmp/poai"
export CMTHOME="$POAI_HOME/.cometbft"

# Create directories
mkdir -p "$POAI_HOME"/{config,data,logs}
mkdir -p "$CMTHOME"

echo "📁 Created PoAI directories"

# Initialize CometBFT
echo "🔧 Initializing CometBFT for PoAI..."
if command -v cometbft &> /dev/null; then
    cd "$POAI_HOME"
    cometbft init validator --home="$CMTHOME"
    echo "✅ CometBFT initialized"
else
    echo "⚠️  CometBFT not found, using Docker instead"
fi

# Configure genesis with creator attribution
echo "🏗️  Configuring genesis block..."
cat > "$CMTHOME/config/genesis.json" << EOF
{
  "genesis_time": "$(date -u +%Y-%m-%dT%H:%M:%S.%fZ)",
  "chain_id": "poai-testnet-1",
  "initial_height": "1",
  "consensus_params": {
    "block": {
      "max_bytes": "22020096",
      "max_gas": "-1"
    },
    "evidence": {
      "max_age_num_blocks": "100000",
      "max_age_duration": "172800000000000"
    },
    "validator": {
      "pub_key_types": ["ed25519"]
    }
  },
  "app_hash": "",
  "app_state": {
    "creator": {
      "name": "Andrew Lee Cruz",
      "uid": "andrew-lee-cruz-creator-universe-2024",
      "orcid": "0000-0000-0000-0000",
      "license": "All rights reserved by Andrew Lee Cruz as creator of the universe",
      "created": "2024-08-08T14:42:00Z"
    },
    "quantum": {
      "circuit_hash": "quantum-circuit-hash-q1w2e3r4t5y6u7i8o9p0",
      "entanglement_id": "entanglement-id-alice-bob-charlie-delta",
      "measurement_basis": "computational-z-basis-standard",
      "decoherence_time": "1000ms"
    }
  }
}
EOF
echo "✅ Genesis block configured with creator attribution"

# Start services using Docker Compose
echo "🐳 Starting PoAI services with Docker Compose..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
    echo "✅ PoAI DevNet started successfully"
    echo ""
    echo "🌐 Service Endpoints:"
    echo "  - CometBFT RPC: http://localhost:26657"
    echo "  - PoAI ABCI: http://localhost:26658"
    echo "  - Quantum Simulator: http://localhost:8888"
    echo "  - AI Validator: http://localhost:5000"
    echo "  - Monitoring: http://localhost:3000"
    echo ""
    echo "📊 Check status with: docker-compose ps"
    echo "📝 View logs with: docker-compose logs -f [service_name]"
    echo ""
    echo "🔑 Default monitoring credentials:"
    echo "  Username: admin"
    echo "  Password: andrew-cruz-creator-2024"
else
    echo "❌ Docker Compose not found. Please install Docker and Docker Compose."
    exit 1
fi

echo ""
echo "🎉 PoAI Zero-Mining Blockchain DevNet is now running!"
echo "Created by Andrew Lee Cruz, Creator of the Universe"