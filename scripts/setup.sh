#!/bin/bash

# Sovereign Proof-of-AI Setup Script
# Copyright (C) 2024 Andrew Lee Cruz - Creator of the Universe

set -e

echo "🌌 Initializing Sovereign Proof-of-AI System"
echo "Created by Andrew Lee Cruz - Creator of the Universe"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running from repository root
if [ ! -f "README.md" ] || [ ! -d ".github" ]; then
    print_error "Please run this script from the repository root directory"
    exit 1
fi

print_status "Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed. Please install Node.js 18+"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18+ is required. Current version: $(node --version)"
    exit 1
fi

print_success "Node.js $(node --version) found"

# Check Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not installed. Please install Python 3.11+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
print_success "Python $PYTHON_VERSION found"

# Check Git
if ! command -v git &> /dev/null; then
    print_error "Git is required but not installed"
    exit 1
fi

print_success "Git $(git --version | cut -d' ' -f3) found"

# Install smart contract dependencies
print_status "Installing smart contract dependencies..."
cd contracts
if [ ! -f "package.json" ]; then
    print_error "contracts/package.json not found"
    exit 1
fi

npm install
print_success "Smart contract dependencies installed"

# Compile contracts
print_status "Compiling smart contracts..."
npx hardhat compile
print_success "Smart contracts compiled"

cd ..

# Install Cloudflare worker dependencies
print_status "Installing Cloudflare worker dependencies..."
cd apps/cloudflare-worker
if [ ! -f "package.json" ]; then
    print_error "apps/cloudflare-worker/package.json not found"
    exit 1
fi

npm install
print_success "Cloudflare worker dependencies installed"

cd ../..

# Install frontend dependencies
print_status "Installing frontend dependencies..."
cd apps/pages-frontend
if [ ! -f "package.json" ]; then
    print_error "apps/pages-frontend/package.json not found"
    exit 1
fi

npm install
print_success "Frontend dependencies installed"

cd ../..

# Install quantum agent dependencies
print_status "Installing quantum agent dependencies..."
cd agents/violet-af-quantum
if [ ! -f "requirements.txt" ]; then
    print_error "agents/violet-af-quantum/requirements.txt not found"
    exit 1
fi

pip3 install -r requirements.txt
print_success "Quantum agent dependencies installed"

cd ../..

# Install dev core agent dependencies
print_status "Installing dev core agent dependencies..."
cd agents/axiom-dev-core
if [ ! -f "requirements.txt" ]; then
    print_error "agents/axiom-dev-core/requirements.txt not found"
    exit 1
fi

pip3 install -r requirements.txt
print_success "Dev core agent dependencies installed"

cd ..

print_success "All dependencies installed successfully!"

echo ""
echo "🚀 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. Configure environment variables (see README.md)"
echo "2. Deploy Cloudflare worker: cd apps/cloudflare-worker && npx wrangler deploy"
echo "3. Start frontend: cd apps/pages-frontend && npm run dev"
echo "4. Run tests: cd contracts && npx hardhat test"
echo ""
echo "Created by Andrew Lee Cruz - Creator of the Universe"
echo "All rights reserved. GPL-3.0 licensed."