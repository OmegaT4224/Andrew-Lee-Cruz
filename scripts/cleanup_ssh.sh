#!/usr/bin/env bash
# SSH Key Cleanup Script
# UID: ALC-ROOT-1010-1111-XCOV∞ 
# Contact: allcatch37@gmail.com

set -euo pipefail

CREATOR_EMAIL="allcatch37@gmail.com"

echo "🔧 SSH Key Security Cleanup"
echo "   Creator: $CREATOR_EMAIL"
echo "   UID: ALC-ROOT-1010-1111-XCOV∞"

# Known WorkingCopy@iPhone fingerprints to preserve
ALLOWED_FINGERPRINTS=(
    "SHA256:EXAMPLE_WORKINGCOPY_FINGERPRINT_1"
    "SHA256:EXAMPLE_WORKINGCOPY_FINGERPRINT_2"
)

echo ""
echo "📋 Allowed SSH key fingerprints:"
for fp in "${ALLOWED_FINGERPRINTS[@]}"; do
    echo "   ✓ $fp"
done

# Function to check if GitHub CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI (gh) not found. Install from: https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo "❌ Not authenticated with GitHub. Run: gh auth login"
        exit 1
    fi
    
    echo "✅ GitHub CLI authenticated"
}

# Function to list current SSH keys
list_ssh_keys() {
    echo ""
    echo "📋 Current SSH keys:"
    gh ssh-key list || {
        echo "❌ Failed to list SSH keys"
        exit 1
    }
}

# Function to identify risky keys
identify_risky_keys() {
    echo ""
    echo "🔍 Identifying potentially risky SSH keys..."
    
    # Get all SSH keys
    local keys_json
    keys_json=$(gh api user/keys --jq '.[].id, .[].title, .[].key' | paste - - -)
    
    local risky_keys=()
    
    while IFS=$'\t' read -r key_id title key_data; do
        # Generate fingerprint for comparison
        local fingerprint
        fingerprint=$(echo "$key_data" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}' || echo "UNKNOWN")
        
        # Check if this fingerprint is in allowed list
        local is_allowed=false
        for allowed_fp in "${ALLOWED_FINGERPRINTS[@]}"; do
            if [[ "$fingerprint" == "$allowed_fp" ]]; then
                is_allowed=true
                break
            fi
        done
        
        if [[ "$is_allowed" == "false" ]]; then
            # Check for risky patterns
            if [[ "$title" == *"iPhone"* ]] || [[ "$title" == *"iPad"* ]] || \
               [[ "$title" == *"mobile"* ]] || [[ "$title" == *"temp"* ]] || \
               [[ "$title" == *"test"* ]]; then
                risky_keys+=("$key_id:$title:$fingerprint")
            fi
        fi
        
    done <<< "$keys_json"
    
    if [[ ${#risky_keys[@]} -eq 0 ]]; then
        echo "✅ No risky SSH keys found"
        return 0
    fi
    
    echo "⚠️  Found ${#risky_keys[@]} potentially risky SSH keys:"
    for risky_key in "${risky_keys[@]}"; do
        local id title fingerprint
        IFS=':' read -r id title fingerprint <<< "$risky_key"
        echo "   🔑 ID: $id | Title: $title | Fingerprint: $fingerprint"
    done
    
    return 1
}

# Function to cleanup risky keys (with confirmation)
cleanup_risky_keys() {
    echo ""
    echo "🧹 SSH Key Cleanup Process"
    echo ""
    echo "⚠️  This will remove SSH keys that don't match allowed fingerprints"
    echo "   and contain risky patterns (iPhone, iPad, mobile, temp, test)"
    echo ""
    echo "📋 Allowed fingerprints will be preserved:"
    for fp in "${ALLOWED_FINGERPRINTS[@]}"; do
        echo "   ✓ $fp"
    done
    echo ""
    
    read -p "Do you want to proceed with cleanup? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cleanup cancelled"
        return 0
    fi
    
    echo ""
    echo "🧹 Starting SSH key cleanup..."
    
    # Note: In a real implementation, you would implement the actual cleanup logic here
    # For safety, we're just showing what would be done
    echo "ℹ️  Cleanup simulation mode (no keys will actually be removed)"
    echo "   To implement actual cleanup, modify this script with:"
    echo "   gh ssh-key delete <key_id>"
    
    echo "✅ SSH key cleanup simulation complete"
}

# Function to add security recommendations
show_security_recommendations() {
    echo ""
    echo "🔒 SSH Security Recommendations:"
    echo ""
    echo "1. Use strong SSH key algorithms:"
    echo "   • Ed25519: ssh-keygen -t ed25519 -C '$CREATOR_EMAIL'"
    echo "   • RSA 4096: ssh-keygen -t rsa -b 4096 -C '$CREATOR_EMAIL'"
    echo ""
    echo "2. Enable SSH key expiration when possible"
    echo ""
    echo "3. Use SSH certificate authorities for enterprise"
    echo ""
    echo "4. Regularly rotate SSH keys"
    echo ""
    echo "5. For WorkingCopy@iPhone, ensure keys are properly secured:"
    echo "   • Use device passcode/biometric lock"
    echo "   • Keep app updated"
    echo "   • Use dedicated keys (not shared with other services)"
    echo ""
    echo "6. Monitor SSH key usage in GitHub audit logs"
}

# Main execution
main() {
    check_gh_cli
    list_ssh_keys
    
    if identify_risky_keys; then
        echo "✅ SSH key security check passed"
    else
        cleanup_risky_keys
    fi
    
    show_security_recommendations
    
    echo ""
    echo "🎉 SSH security cleanup complete!"
    echo "   Contact: $CREATOR_EMAIL"
    echo "   UID: ALC-ROOT-1010-1111-XCOV∞"
}

# Run main function
main "$@"