#!/bin/bash
# worker_env.sh - Set Cloudflare Worker secrets
# Author: Andrew Lee Cruz <allcatch37@gmail.com>
# UID: ALC-ROOT-1010-1111-XCOV∞

set -e

WORKER_NAME="omegat-cloudflare-chain"
CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"
CREATOR_EMAIL="allcatch37@gmail.com"

echo "🔧 Setting up Cloudflare Worker environment secrets..."
echo "   Worker: $WORKER_NAME"
echo "   UID: $CREATOR_UID"
echo "   Email: $CREATOR_EMAIL"

# Check if wrangler is available
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI is not installed. Please install it first:"
    echo "   npm install -g wrangler"
    exit 1
fi

# Check if authenticated
if ! wrangler whoami &> /dev/null; then
    echo "❌ Not authenticated with Cloudflare. Please run 'wrangler login' first."
    exit 1
fi

echo "✅ Wrangler authenticated"

# Function to set secret safely
set_secret() {
    local secret_name="$1"
    local secret_value="$2"
    local environment="$3"
    
    echo "🔐 Setting secret: $secret_name"
    
    if [ -n "$environment" ]; then
        echo "$secret_value" | wrangler secret put "$secret_name" --name "$WORKER_NAME" --env "$environment"
    else
        echo "$secret_value" | wrangler secret put "$secret_name" --name "$WORKER_NAME"
    fi
    
    echo "✅ Secret $secret_name set successfully"
}

# Function to set up development environment
setup_dev_environment() {
    echo "🧪 Setting up development environment secrets..."
    
    set_secret "CREATOR_UID" "$CREATOR_UID" ""
    set_secret "CREATOR_EMAIL" "$CREATOR_EMAIL" ""
    
    # Prompt for GitHub token if not set
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "🔑 GitHub token required for project scaffolding."
        echo "   Please create a Personal Access Token with repo permissions at:"
        echo "   https://github.com/settings/personal-access-tokens/new"
        echo
        read -s -p "Enter GitHub token: " GITHUB_TOKEN
        echo
    fi
    
    set_secret "GITHUB_TOKEN" "$GITHUB_TOKEN" ""
    
    echo "✅ Development environment configured"
}

# Function to set up production environment
setup_prod_environment() {
    echo "🚀 Setting up production environment secrets..."
    
    set_secret "CREATOR_UID" "$CREATOR_UID" "production"
    set_secret "CREATOR_EMAIL" "$CREATOR_EMAIL" "production"
    
    # Prompt for production GitHub token if not set
    if [ -z "$GITHUB_TOKEN_PROD" ]; then
        echo "🔑 Production GitHub token required."
        echo "   This should be a separate token with limited scope for production use."
        echo
        read -s -p "Enter production GitHub token: " GITHUB_TOKEN_PROD
        echo
    fi
    
    set_secret "GITHUB_TOKEN" "$GITHUB_TOKEN_PROD" "production"
    
    echo "✅ Production environment configured"
}

# Function to verify secrets
verify_secrets() {
    local environment="$1"
    
    echo "🔍 Verifying secrets for $environment environment..."
    
    if [ -n "$environment" ]; then
        wrangler secret list --name "$WORKER_NAME" --env "$environment"
    else
        wrangler secret list --name "$WORKER_NAME"
    fi
    
    echo "✅ Secrets verified"
}

# Function to show usage
usage() {
    echo "Usage: $0 [dev|prod|both]"
    echo
    echo "Commands:"
    echo "  dev   - Set up development environment secrets only"
    echo "  prod  - Set up production environment secrets only"
    echo "  both  - Set up both development and production environments"
    echo
    echo "Environment variables:"
    echo "  GITHUB_TOKEN      - GitHub token for development"
    echo "  GITHUB_TOKEN_PROD - GitHub token for production"
    echo
    exit 1
}

# Main execution
main() {
    local command="${1:-both}"
    
    echo "🚀 Starting Cloudflare Worker environment setup..."
    echo
    
    case "$command" in
        "dev")
            setup_dev_environment
            echo
            verify_secrets ""
            ;;
        "prod")
            setup_prod_environment  
            echo
            verify_secrets "production"
            ;;
        "both")
            setup_dev_environment
            echo
            setup_prod_environment
            echo
            verify_secrets ""
            echo
            verify_secrets "production"
            ;;
        *)
            usage
            ;;
    esac
    
    echo
    echo "🎉 Cloudflare Worker environment setup completed!"
    echo
    echo "📋 Summary:"
    echo "   ✅ CREATOR_UID set to: $CREATOR_UID"
    echo "   ✅ CREATOR_EMAIL set to: $CREATOR_EMAIL" 
    echo "   ✅ GITHUB_TOKEN configured"
    echo
    echo "⚠️  Important security notes:"
    echo "   - Keep your GitHub tokens secure and rotate them regularly"
    echo "   - Use separate tokens for development and production"
    echo "   - Monitor token usage in GitHub settings"
    echo "   - Revoke tokens immediately if compromised"
}

# Run main function
main "$@"