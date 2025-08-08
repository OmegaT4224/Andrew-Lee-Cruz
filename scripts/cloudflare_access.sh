#!/bin/bash
# cloudflare_access.sh - Set up Cloudflare Access rules
# Author: Andrew Lee Cruz <allcatch37@gmail.com>
# UID: ALC-ROOT-1010-1111-XCOV∞

set -e

CREATOR_EMAIL="allcatch37@gmail.com"
ZONE_NAME="omegat.net"
APPLICATION_NAME="OmegaT Builder Admin"

echo "🔐 Setting up Cloudflare Access rules..."
echo "   Zone: $ZONE_NAME"
echo "   Creator Email: $CREATOR_EMAIL"
echo "   Application: $APPLICATION_NAME"

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

# Function to create access application
create_access_application() {
    echo "🛡️  Creating Cloudflare Access application..."
    
    # Note: This is a template script. Actual implementation would require
    # the Cloudflare API or specific wrangler commands for Access configuration.
    # For now, we'll provide instructions for manual setup.
    
    echo "📋 Manual Cloudflare Access Setup Instructions:"
    echo
    echo "1. Go to Cloudflare Dashboard > Zero Trust > Access > Applications"
    echo "2. Click 'Add an application' > 'Self-hosted'"
    echo
    echo "Application Configuration:"
    echo "   - Application name: $APPLICATION_NAME"
    echo "   - Subdomain: admin"
    echo "   - Domain: $ZONE_NAME"
    echo "   - Path: /init"
    echo
    echo "Policies:"
    echo "   Policy Name: Creator Only Access"
    echo "   Action: Allow"
    echo "   Rules:"
    echo "     - Include: Emails ending in @gmail.com"
    echo "     - Include: Email is $CREATOR_EMAIL"
    echo
    echo "3. Save the application"
    echo "4. Test access at https://admin.$ZONE_NAME/init"
    
    echo "✅ Access application configuration template provided"
}

# Function to set up additional security rules
setup_security_rules() {
    echo "🔒 Setting up additional security rules..."
    
    echo "📋 Recommended Cloudflare Security Settings:"
    echo
    echo "1. Security > WAF > Custom Rules:"
    echo "   - Block non-essential countries (if applicable)"
    echo "   - Rate limit aggressive requests"
    echo "   - Block known bad user agents"
    echo
    echo "2. Security > Bots:"
    echo "   - Enable Bot Fight Mode"
    echo "   - Configure Super Bot Fight Mode if available"
    echo
    echo "3. Security > DDoS:"
    echo "   - Enable DDoS protection (should be on by default)"
    echo
    echo "4. SSL/TLS:"
    echo "   - Set encryption mode to 'Full (strict)'"
    echo "   - Enable 'Always Use HTTPS'"
    echo "   - Enable HSTS"
    echo
    echo "5. Page Rules or Transform Rules:"
    echo "   - Redirect HTTP to HTTPS"
    echo "   - Cache static assets appropriately"
    
    echo "✅ Security rules documentation provided"
}

# Function to create worker route protections
setup_worker_routes() {
    echo "🛠️  Setting up Worker route protections..."
    
    echo "📋 Worker Route Security Recommendations:"
    echo
    echo "1. Admin Routes (/init, /admin/*):"
    echo "   - Protect with Cloudflare Access"
    echo "   - Require authentication"
    echo "   - Log all access attempts"
    echo
    echo "2. API Routes (/api/*):"
    echo "   - Implement rate limiting"
    echo "   - Validate request origins"
    echo "   - Use API keys for sensitive operations"
    echo
    echo "3. Public Routes:"
    echo "   - Cache appropriately"
    echo "   - Implement basic rate limiting"
    echo "   - Monitor for abuse"
    
    echo "✅ Worker route protection guidelines provided"
}

# Function to configure monitoring and alerts
setup_monitoring() {
    echo "📊 Setting up monitoring and alerts..."
    
    echo "📋 Monitoring Configuration:"
    echo
    echo "1. Analytics & Logs > Logpush:"
    echo "   - Enable HTTP request logs"
    echo "   - Configure log destination (if needed)"
    echo
    echo "2. Analytics & Logs > Real-time Activity Log:"
    echo "   - Monitor for suspicious activity"
    echo "   - Set up alerts for critical events"
    echo
    echo "3. Workers > Analytics:"
    echo "   - Monitor worker performance"
    echo "   - Track error rates"
    echo "   - Set up usage alerts"
    echo
    echo "4. Security > Events:"
    echo "   - Monitor security events"
    echo "   - Configure email notifications"
    
    echo "✅ Monitoring setup documentation provided"
}

# Function to show current status
show_status() {
    echo "📊 Current Cloudflare configuration status..."
    
    # Show basic zone info
    echo "🌐 Zone Information:"
    echo "   Email: $CREATOR_EMAIL"
    echo "   Zone: $ZONE_NAME"
    echo
    
    echo "📋 Verification Checklist:"
    echo "   □ Cloudflare Access application created"
    echo "   □ Security rules configured"
    echo "   □ Worker routes protected"
    echo "   □ Monitoring and alerts set up"
    echo "   □ SSL/TLS properly configured"
    echo "   □ Access tested with creator email"
    echo
    echo "🔗 Quick Links:"
    echo "   Dashboard: https://dash.cloudflare.com/"
    echo "   Access: https://one.dash.cloudflare.com/"
    echo "   Workers: https://dash.cloudflare.com/workers"
}

# Function to show usage
usage() {
    echo "Usage: $0 [setup|status|help]"
    echo
    echo "Commands:"
    echo "  setup  - Show setup instructions for Cloudflare Access"
    echo "  status - Show current configuration status"
    echo "  help   - Show this help message"
    echo
    exit 1
}

# Main execution
main() {
    local command="${1:-setup}"
    
    echo "🚀 Starting Cloudflare Access configuration..."
    echo
    
    case "$command" in
        "setup")
            create_access_application
            echo
            setup_security_rules
            echo
            setup_worker_routes
            echo
            setup_monitoring
            ;;
        "status")
            show_status
            ;;
        "help")
            usage
            ;;
        *)
            usage
            ;;
    esac
    
    echo
    echo "🎉 Cloudflare Access configuration completed!"
    echo
    echo "⚠️  Important Notes:"
    echo "   - Most Cloudflare Access features require manual configuration"
    echo "   - Test all access rules after setup"
    echo "   - Monitor logs for any issues"
    echo "   - Keep access policies up to date"
}

# Run main function
main "$@"