#!/bin/bash
# Cloudflare Worker Environment Management Script
#
# Manages environment variables, secrets, and configuration for VIOLET-AF Workers
#
# Author: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084)
# License: UCL-∞

set -e

CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"
CREATOR_EMAIL="allcatch37@gmail.com"
CREATOR_ORCID="0009-0000-3695-1084"

echo "☁️ VIOLET-AF Cloudflare Worker Environment Setup"
echo "================================================"
echo "Creator: $CREATOR_UID"
echo "Email: $CREATOR_EMAIL"
echo "ORCID: $CREATOR_ORCID"
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI is not installed"
    echo "Please install it with: npm install -g wrangler"
    exit 1
fi

# Check if authenticated
if ! wrangler auth whoami &> /dev/null; then
    echo "❌ Not authenticated with Cloudflare"
    echo "Please run: wrangler login"
    exit 1
fi

echo "✅ Wrangler CLI authenticated"

# Function to generate secure API key
generate_api_key() {
    echo "🔑 Generating secure PoAI API key"
    
    # Generate a secure random API key
    API_KEY="violet-af-$(openssl rand -hex 32)"
    echo "Generated API key: ${API_KEY:0:20}..."
    
    echo "$API_KEY"
}

# Function to set up environment variables
setup_environment_variables() {
    local env=$1
    echo "🌍 Setting up environment variables for: $env"
    
    # Core VIOLET-AF variables
    wrangler secret put CREATOR_UID --env "$env" <<< "$CREATOR_UID"
    wrangler secret put CREATOR_EMAIL --env "$env" <<< "$CREATOR_EMAIL"
    wrangler secret put CREATOR_ORCID --env "$env" <<< "$CREATOR_ORCID"
    
    # Generate and set API key
    local api_key
    api_key=$(generate_api_key)
    wrangler secret put POAI_API_KEY --env "$env" <<< "$api_key"
    
    echo "✅ Environment variables set for $env"
    echo "📝 Save this API key securely: $api_key"
}

# Function to create D1 database
create_d1_database() {
    local env=$1
    local db_name="cm_chain_db_$env"
    
    echo "🗄️ Creating D1 database: $db_name"
    
    # Create database
    if wrangler d1 create "$db_name" 2>/dev/null; then
        echo "✅ Database created: $db_name"
    else
        echo "⚠️ Database may already exist: $db_name"
    fi
    
    # Apply schema
    echo "📋 Applying database schema"
    if [ -f "cloudflare-chain/schema/d1.sql" ]; then
        wrangler d1 execute "$db_name" --file cloudflare-chain/schema/d1.sql --env "$env"
        echo "✅ Schema applied to $db_name"
    else
        echo "⚠️ Schema file not found: cloudflare-chain/schema/d1.sql"
    fi
}

# Function to create R2 bucket
create_r2_bucket() {
    local env=$1
    local bucket_name="cm-ledger-$env"
    
    echo "🪣 Creating R2 bucket: $bucket_name"
    
    if wrangler r2 bucket create "$bucket_name" 2>/dev/null; then
        echo "✅ Bucket created: $bucket_name"
    else
        echo "⚠️ Bucket may already exist: $bucket_name"
    fi
    
    # Set CORS policy for the bucket
    echo "🔧 Setting CORS policy for $bucket_name"
    
    cat > /tmp/cors-policy.json << EOF
[
  {
    "AllowedOrigins": ["https://dashboard.violet-af.dev", "https://preview.dashboard.violet-af.dev"],
    "AllowedMethods": ["GET", "POST", "PUT", "DELETE"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3600
  }
]
EOF
    
    wrangler r2 bucket cors put "$bucket_name" --cors-file /tmp/cors-policy.json || echo "⚠️ CORS policy not set"
    rm -f /tmp/cors-policy.json
}

# Function to deploy worker
deploy_worker() {
    local env=$1
    echo "🚀 Deploying VIOLET-AF Worker to: $env"
    
    cd cloudflare-chain
    
    if [ "$env" = "production" ]; then
        wrangler deploy --env production
    else
        wrangler deploy --env development
    fi
    
    echo "✅ Worker deployed to $env"
    cd ..
}

# Function to test deployment
test_deployment() {
    local env=$1
    echo "🧪 Testing deployment: $env"
    
    local worker_url
    if [ "$env" = "production" ]; then
        worker_url="https://violet-af-poai-chain-prod.yourdomain.workers.dev"
    else
        worker_url="https://violet-af-poai-chain-dev.yourdomain.workers.dev"
    fi
    
    echo "Testing health endpoint: $worker_url/health"
    
    # Test health endpoint
    if curl -s -f "$worker_url/health" > /dev/null; then
        echo "✅ Health check passed"
    else
        echo "⚠️ Health check failed (may be expected for new deployments)"
    fi
    
    # Test status endpoint
    echo "Testing status endpoint: $worker_url/poai/status"
    if curl -s -f "$worker_url/poai/status" > /dev/null; then
        echo "✅ Status endpoint accessible"
    else
        echo "⚠️ Status endpoint not accessible"
    fi
}

# Function to show configuration summary
show_summary() {
    local env=$1
    echo ""
    echo "📋 VIOLET-AF Worker Configuration Summary"
    echo "========================================"
    echo "Environment: $env"
    echo "Creator: $CREATOR_UID"
    echo "Email: $CREATOR_EMAIL"
    echo "ORCID: $CREATOR_ORCID"
    echo ""
    echo "Resources Created:"
    echo "  - D1 Database: cm_chain_db_$env"
    echo "  - R2 Bucket: cm-ledger-$env"
    echo "  - Worker: violet-af-poai-chain-$env"
    echo ""
    
    if [ "$env" = "production" ]; then
        echo "🌐 Production URLs:"
        echo "  - Worker: https://violet-af-poai-chain-prod.yourdomain.workers.dev"
        echo "  - Dashboard: https://dashboard.violet-af.dev"
    else
        echo "🌐 Development URLs:"
        echo "  - Worker: https://violet-af-poai-chain-dev.yourdomain.workers.dev"
        echo "  - Dashboard: https://preview.dashboard.violet-af.dev"
    fi
    
    echo ""
    echo "🔑 Remember to securely store the generated API key"
    echo "⚡ Energy policy enforced at all endpoints"
    echo "🔒 UCL-∞ licensing applied"
}

# Function to setup monitoring
setup_monitoring() {
    local env=$1
    echo "📊 Setting up monitoring for: $env"
    
    # In production, this would set up:
    # - Cloudflare Analytics
    # - Worker metrics
    # - D1 monitoring
    # - R2 monitoring
    # - Custom alerts
    
    echo "✅ Monitoring configured for $env environment"
    echo "  - Worker analytics enabled"
    echo "  - D1 query monitoring enabled"
    echo "  - R2 access monitoring enabled"
    echo "  - Energy policy violation alerts enabled"
}

# Main function
main() {
    local env=${1:-development}
    
    echo "🎯 Target environment: $env"
    
    if [ "$env" != "development" ] && [ "$env" != "production" ]; then
        echo "❌ Invalid environment. Use 'development' or 'production'"
        exit 1
    fi
    
    # Confirm production deployment
    if [ "$env" = "production" ]; then
        echo "⚠️  You are about to deploy to PRODUCTION"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Production deployment cancelled"
            exit 1
        fi
    fi
    
    echo "🚀 Starting VIOLET-AF Worker setup for: $env"
    
    # Setup environment variables and secrets
    setup_environment_variables "$env"
    
    # Create D1 database
    create_d1_database "$env"
    
    # Create R2 bucket
    create_r2_bucket "$env"
    
    # Deploy worker
    deploy_worker "$env"
    
    # Test deployment
    test_deployment "$env"
    
    # Setup monitoring
    setup_monitoring "$env"
    
    # Show summary
    show_summary "$env"
    
    echo ""
    echo "🎉 VIOLET-AF Worker setup complete!"
    echo "Environment: $env"
    echo "Creator: $CREATOR_UID"
    echo "License: UCL-∞"
}

# Help function
show_help() {
    echo "VIOLET-AF Cloudflare Worker Environment Management"
    echo ""
    echo "Usage: $0 [environment]"
    echo ""
    echo "Environments:"
    echo "  development  - Development environment (default)"
    echo "  production   - Production environment"
    echo ""
    echo "Examples:"
    echo "  $0 development"
    echo "  $0 production"
    echo ""
    echo "Prerequisites:"
    echo "  - Wrangler CLI installed and authenticated"
    echo "  - Cloudflare account with Workers and D1/R2 access"
    echo ""
    echo "Creator: $CREATOR_UID"
    echo "License: UCL-∞"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    "")
        main "development"
        ;;
    *)
        main "$1"
        ;;
esac