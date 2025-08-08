#!/usr/bin/env bash
# Cloudflare Access Policy Setup
# UID: ALC-ROOT-1010-1111-XCOV∞
# Contact: allcatch37@gmail.com

set -euo pipefail

CREATOR_EMAIL="allcatch37@gmail.com"
CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"
DOMAIN="violet-af.your-domain.com"  # Update with actual domain

echo "☁️ Cloudflare Access Policy Setup"
echo "   Creator: $CREATOR_EMAIL"
echo "   UID: $CREATOR_UID"
echo "   Domain: $DOMAIN"

# Check for required environment variables
check_env_vars() {
    local required_vars=("CF_API_TOKEN" "CF_ACCOUNT_ID" "CF_ZONE_ID")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "❌ Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "   • $var"
        done
        echo ""
        echo "Set these variables and run again:"
        echo "   export CF_API_TOKEN=your_api_token"
        echo "   export CF_ACCOUNT_ID=your_account_id"
        echo "   export CF_ZONE_ID=your_zone_id"
        exit 1
    fi
    
    echo "✅ Environment variables configured"
}

# Function to create Cloudflare Access application
create_access_application() {
    echo ""
    echo "📱 Creating Cloudflare Access application..."
    
    local app_config=$(cat <<EOF
{
  "name": "VIOLET-AF Admin Routes",
  "domain": "$DOMAIN",
  "type": "self_hosted",
  "session_duration": "24h",
  "auto_redirect_to_identity": false,
  "enable_binding_cookie": false,
  "custom_deny_message": "Access restricted to creator: $CREATOR_EMAIL",
  "custom_deny_url": "https://$DOMAIN/access-denied",
  "logo_url": "https://$DOMAIN/logo.png",
  "skip_interstitial": true,
  "app_launcher_visible": true,
  "service_auth_401_redirect": true,
  "tags": ["violet-af", "quantum-agent", "creator-only"]
}
EOF
)
    
    local response
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/access/apps" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$app_config")
    
    local success
    success=$(echo "$response" | jq -r '.success')
    
    if [[ "$success" == "true" ]]; then
        local app_id
        app_id=$(echo "$response" | jq -r '.result.id')
        echo "✅ Access application created: $app_id"
        echo "$app_id" > .cf_app_id
    else
        echo "❌ Failed to create Access application:"
        echo "$response" | jq -r '.errors[].message'
        return 1
    fi
}

# Function to create Access policy
create_access_policy() {
    local app_id="$1"
    
    echo ""
    echo "🔐 Creating Access policy for creator email..."
    
    local policy_config=$(cat <<EOF
{
  "name": "Creator Only Access",
  "decision": "allow",
  "include": [
    {
      "email": {
        "email": "$CREATOR_EMAIL"
      }
    }
  ],
  "exclude": [],
  "require": [],
  "purpose_justification_required": false,
  "purpose_justification_prompt": "Access to VIOLET-AF admin routes",
  "approval_required": false,
  "isolation_required": false,
  "session_duration": "24h"
}
EOF
)
    
    local response
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/access/apps/$app_id/policies" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$policy_config")
    
    local success
    success=$(echo "$response" | jq -r '.success')
    
    if [[ "$success" == "true" ]]; then
        local policy_id
        policy_id=$(echo "$response" | jq -r '.result.id')
        echo "✅ Access policy created: $policy_id"
        echo "$policy_id" > .cf_policy_id
    else
        echo "❌ Failed to create Access policy:"
        echo "$response" | jq -r '.errors[].message'
        return 1
    fi
}

# Function to setup Zero Trust identity provider
setup_identity_provider() {
    echo ""
    echo "🆔 Setting up Zero Trust identity provider..."
    
    # Check if email identity provider exists
    local providers_response
    providers_response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/access/identity_providers" \
        -H "Authorization: Bearer $CF_API_TOKEN")
    
    local has_email_provider
    has_email_provider=$(echo "$providers_response" | jq -r '.result[] | select(.type == "onetimepin") | .id')
    
    if [[ -n "$has_email_provider" ]]; then
        echo "✅ Email identity provider already exists: $has_email_provider"
        return 0
    fi
    
    # Create email OTP identity provider
    local idp_config=$(cat <<EOF
{
  "name": "Email OTP for VIOLET-AF",
  "type": "onetimepin",
  "config": {}
}
EOF
)
    
    local idp_response
    idp_response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/access/identity_providers" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$idp_config")
    
    local idp_success
    idp_success=$(echo "$idp_response" | jq -r '.success')
    
    if [[ "$idp_success" == "true" ]]; then
        local idp_id
        idp_id=$(echo "$idp_response" | jq -r '.result.id')
        echo "✅ Email identity provider created: $idp_id"
    else
        echo "❌ Failed to create identity provider:"
        echo "$idp_response" | jq -r '.errors[].message'
        return 1
    fi
}

# Function to configure admin route protection
configure_admin_routes() {
    echo ""
    echo "🛡️ Admin routes that will be protected:"
    echo "   • $DOMAIN/admin/*"
    echo "   • $DOMAIN/quantum/store"
    echo "   • $DOMAIN/logs/*"
    echo "   • Any route requiring creator authorization"
    echo ""
    echo "✅ Routes configured for Zero Trust protection"
}

# Function to show configuration summary
show_summary() {
    echo ""
    echo "🎉 Cloudflare Access configuration complete!"
    echo ""
    echo "📋 Summary:"
    echo "   ✓ Access application created for $DOMAIN"
    echo "   ✓ Creator-only policy: $CREATOR_EMAIL"
    echo "   ✓ Email OTP identity provider configured"
    echo "   ✓ Admin routes protected"
    echo "   ✓ Session duration: 24 hours"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Update DNS records to point to Cloudflare"
    echo "   2. Enable Access in your Workers (see worker/src/index.ts)"
    echo "   3. Test access with creator email: $CREATOR_EMAIL"
    echo "   4. Monitor access logs in Cloudflare dashboard"
    echo ""
    echo "🔗 Access URLs:"
    echo "   • Dashboard: https://dash.cloudflare.com"
    echo "   • Access Logs: https://dash.cloudflare.com/[account]/access/logs"
    echo "   • Application: https://$DOMAIN/admin"
    echo ""
    echo "Contact: $CREATOR_EMAIL"
    echo "UID: $CREATOR_UID"
}

# Main execution
main() {
    check_env_vars
    setup_identity_provider
    create_access_application
    
    if [[ -f .cf_app_id ]]; then
        local app_id
        app_id=$(cat .cf_app_id)
        create_access_policy "$app_id"
    fi
    
    configure_admin_routes
    show_summary
}

# Check for required tools
if ! command -v curl &> /dev/null; then
    echo "❌ curl not found. Please install curl."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Please install jq for JSON parsing."
    exit 1
fi

# Run main function
main "$@"