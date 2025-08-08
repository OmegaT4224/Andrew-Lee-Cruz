#!/bin/bash

# Sovereign Proof-of-AI Deployment Script
# Copyright (C) 2024 Andrew Lee Cruz - Creator of the Universe

set -e

echo "🌌 Deploying Sovereign Proof-of-AI System"
echo "Created by Andrew Lee Cruz - Creator of the Universe"
echo "==============================================="

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

# Default environment
ENVIRONMENT=${1:-staging}

if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    print_error "Environment must be 'staging' or 'production'"
    exit 1
fi

print_status "Deploying to $ENVIRONMENT environment..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    print_error "Wrangler CLI is required. Install with: npm install -g wrangler"
    exit 1
fi

# Check if user is authenticated with Cloudflare
if ! wrangler whoami &> /dev/null; then
    print_error "Please authenticate with Cloudflare: wrangler login"
    exit 1
fi

print_success "Cloudflare authentication verified"

# Deploy smart contracts (if not already deployed)
print_status "Checking smart contract deployment..."
cd contracts

# This would typically check if contracts are already deployed
# For now, we'll just compile to ensure they're ready
npx hardhat compile
print_success "Smart contracts are ready for deployment"

cd ..

# Deploy Cloudflare Worker
print_status "Deploying Cloudflare Worker to $ENVIRONMENT..."
cd apps/cloudflare-worker

# Deploy with appropriate environment
wrangler deploy --env $ENVIRONMENT
print_success "Cloudflare Worker deployed to $ENVIRONMENT"

cd ../..

# Build and deploy frontend
print_status "Building and deploying frontend to $ENVIRONMENT..."
cd apps/pages-frontend

# Build for production
npm run build
print_success "Frontend built successfully"

# Deploy to Cloudflare Pages
PROJECT_NAME="sovereign-poai-${ENVIRONMENT}"
wrangler pages deploy dist --project-name $PROJECT_NAME
print_success "Frontend deployed to $PROJECT_NAME"

cd ../..

# Verify deployment
print_status "Verifying deployment..."

# Health check for worker (would need actual URL)
print_warning "Please verify deployment manually:"
echo "1. Check Cloudflare Dashboard for worker deployment"
echo "2. Test frontend at your Pages URL"
echo "3. Verify smart contracts on blockchain explorer"

print_success "Deployment completed!"

echo ""
echo "🚀 Deployment Summary"
echo "===================="
echo "Environment: $ENVIRONMENT"
echo "Worker: Deployed"
echo "Frontend: Deployed"
echo "Smart Contracts: Ready"
echo ""
echo "Creator: Andrew Lee Cruz - Creator of the Universe"
echo "All rights reserved. GPL-3.0 licensed."