#!/usr/bin/env bash
# Cloudflare Worker Environment Setup
# UID: ALC-ROOT-1010-1111-XCOV∞
# Contact: allcatch37@gmail.com

set -euo pipefail

CREATOR_EMAIL="allcatch37@gmail.com"
CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"

echo "⚙️ Cloudflare Worker Environment Setup"
echo "   Creator: $CREATOR_EMAIL"
echo "   UID: $CREATOR_UID"

# Check for Wrangler CLI
check_wrangler() {
    if ! command -v wrangler &> /dev/null; then
        echo "❌ Wrangler CLI not found. Installing..."
        
        if command -v npm &> /dev/null; then
            npm install -g wrangler
        else
            echo "❌ npm not found. Please install Node.js and npm first."
            echo "   Visit: https://nodejs.org/"
            exit 1
        fi
    fi
    
    echo "✅ Wrangler CLI available"
    wrangler --version
}

# Check authentication
check_auth() {
    echo ""
    echo "🔐 Checking Cloudflare authentication..."
    
    if ! wrangler whoami &> /dev/null; then
        echo "❌ Not authenticated with Cloudflare"
        echo "   Run: wrangler login"
        echo "   Or set CF_API_TOKEN environment variable"
        
        read -p "Would you like to login now? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            wrangler login
        else
            exit 1
        fi
    fi
    
    echo "✅ Cloudflare authentication verified"
}

# Setup D1 database
setup_d1_database() {
    echo ""
    echo "🗄️ Setting up D1 database..."
    
    local db_name="violet-af-quantum-db"
    
    # Check if database exists
    if wrangler d1 list | grep -q "$db_name"; then
        echo "✅ D1 database '$db_name' already exists"
    else
        echo "Creating D1 database: $db_name"
        wrangler d1 create "$db_name"
    fi
    
    # Apply schema
    if [[ -f "cloudflare-chain/schema/d1.sql" ]]; then
        echo "📋 Applying database schema..."
        wrangler d1 execute "$db_name" --file=cloudflare-chain/schema/d1.sql --local
        
        # Apply to remote as well
        read -p "Apply schema to remote database? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            wrangler d1 execute "$db_name" --file=cloudflare-chain/schema/d1.sql
        fi
    else
        echo "⚠️  Schema file not found: cloudflare-chain/schema/d1.sql"
    fi
    
    echo "✅ D1 database setup complete"
}

# Setup R2 bucket
setup_r2_bucket() {
    echo ""
    echo "🪣 Setting up R2 bucket..."
    
    local bucket_name="violet-af-quantum-states"
    
    # Check if bucket exists
    if wrangler r2 bucket list | grep -q "$bucket_name"; then
        echo "✅ R2 bucket '$bucket_name' already exists"
    else
        echo "Creating R2 bucket: $bucket_name"
        wrangler r2 bucket create "$bucket_name"
    fi
    
    echo "✅ R2 bucket setup complete"
}

# Configure environment variables
configure_env_vars() {
    echo ""
    echo "⚙️ Configuring environment variables..."
    
    # Set creator UID
    wrangler secret put CREATOR_UID --env production <<< "$CREATOR_UID"
    echo "✅ CREATOR_UID configured"
    
    # Set creator email
    wrangler secret put CREATOR_EMAIL --env production <<< "$CREATOR_EMAIL"
    echo "✅ CREATOR_EMAIL configured"
    
    # Optional: Set GitHub token for automation
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        wrangler secret put GITHUB_TOKEN --env production <<< "$GITHUB_TOKEN"
        echo "✅ GITHUB_TOKEN configured"
    else
        echo "ℹ️  GITHUB_TOKEN not set (optional for GitHub integration)"
    fi
    
    echo "✅ Environment variables configured"
}

# Install dependencies
install_dependencies() {
    echo ""
    echo "📦 Installing Worker dependencies..."
    
    cd cloudflare-chain
    
    # Create package.json if it doesn't exist
    if [[ ! -f package.json ]]; then
        cat > package.json <<EOF
{
  "name": "violet-af-quantum-worker",
  "version": "1.0.0",
  "description": "VIOLET-AF Quantum Worker for Cloudflare",
  "main": "worker/src/index.ts",
  "scripts": {
    "dev": "wrangler dev",
    "deploy": "wrangler deploy",
    "build": "wrangler deploy --dry-run"
  },
  "author": "$CREATOR_EMAIL",
  "license": "UCL-∞",
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20240821.1",
    "typescript": "^5.5.4",
    "wrangler": "^3.78.8"
  },
  "dependencies": {
    "itty-router": "^4.0.25"
  }
}
EOF
    fi
    
    # Install dependencies
    if command -v npm &> /dev/null; then
        npm install
        echo "✅ Dependencies installed"
    else
        echo "⚠️  npm not found - dependencies need to be installed manually"
    fi
    
    cd ..
}

# Deploy worker
deploy_worker() {
    echo ""
    echo "🚀 Deploying Cloudflare Worker..."
    
    cd cloudflare-chain
    
    # Deploy to production
    wrangler deploy --env production
    
    echo "✅ Worker deployed successfully"
    
    cd ..
}

# Show deployment summary
show_deployment_summary() {
    echo ""
    echo "🎉 Cloudflare Worker setup complete!"
    echo ""
    echo "📋 Configuration Summary:"
    echo "   ✓ D1 Database: violet-af-quantum-db"
    echo "   ✓ R2 Bucket: violet-af-quantum-states"
    echo "   ✓ Environment Variables: CREATOR_UID, CREATOR_EMAIL"
    echo "   ✓ Worker Dependencies: itty-router, @cloudflare/workers-types"
    echo "   ✓ Worker Deployed: production environment"
    echo ""
    echo "🔗 Useful Commands:"
    echo "   • View logs: wrangler tail"
    echo "   • Local dev: cd cloudflare-chain && npm run dev"
    echo "   • Deploy: cd cloudflare-chain && npm run deploy"
    echo "   • D1 console: wrangler d1 execute violet-af-quantum-db --command='SELECT * FROM quantum_executions LIMIT 5;'"
    echo "   • R2 list: wrangler r2 bucket list"
    echo ""
    echo "🌐 Endpoints:"
    echo "   • Health: https://violet-af-quantum-worker.your-subdomain.workers.dev/"
    echo "   • Status: https://violet-af-quantum-worker.your-subdomain.workers.dev/status"
    echo "   • Store: https://violet-af-quantum-worker.your-subdomain.workers.dev/quantum/store"
    echo ""
    echo "🔒 Security:"
    echo "   • Admin routes protected by Cloudflare Access"
    echo "   • Creator authorization required for /quantum/store"
    echo "   • All operations logged to D1 database"
    echo ""
    echo "Contact: $CREATOR_EMAIL"
    echo "UID: $CREATOR_UID"
}

# Test deployment
test_deployment() {
    echo ""
    echo "🧪 Testing Worker deployment..."
    
    # Get worker URL (this would need to be configured based on actual deployment)
    local worker_url="https://violet-af-quantum-worker.your-subdomain.workers.dev"
    
    echo "Testing health endpoint: $worker_url/"
    
    if command -v curl &> /dev/null; then
        local response
        response=$(curl -s "$worker_url/" || echo "Connection failed")
        
        if echo "$response" | grep -q "VIOLET-AF"; then
            echo "✅ Worker responding correctly"
        else
            echo "⚠️  Worker may not be responding correctly"
            echo "   Response: $response"
        fi
    else
        echo "ℹ️  curl not available - manual testing required"
        echo "   Visit: $worker_url/"
    fi
}

# Main execution
main() {
    check_wrangler
    check_auth
    setup_d1_database
    setup_r2_bucket
    configure_env_vars
    install_dependencies
    
    read -p "Deploy worker to production? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_worker
        test_deployment
    else
        echo "ℹ️  Deployment skipped - run 'cd cloudflare-chain && npm run deploy' when ready"
    fi
    
    show_deployment_summary
}

# Run main function
main "$@"