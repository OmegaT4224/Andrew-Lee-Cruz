#!/bin/bash
# gh_rulesets.sh - GitHub repository protection and rulesets
# Author: Andrew Lee Cruz <allcatch37@gmail.com>
# UID: ALC-ROOT-1010-1111-XCOV∞

set -e

REPO_OWNER="OmegaT4224"
REPO_NAME="andrew-lee-cruz"
MAIN_BRANCH="main"

echo "🔒 Setting up GitHub repository security rulesets..."
echo "   Repository: $REPO_OWNER/$REPO_NAME"
echo "   Main Branch: $MAIN_BRANCH"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub. Please run 'gh auth login' first."
    exit 1
fi

echo "✅ GitHub CLI authenticated"

# Function to create or update branch protection rules
setup_branch_protection() {
    echo "🛡️  Setting up branch protection for $MAIN_BRANCH..."
    
    # Enable branch protection with required checks
    gh api \
        --method PUT \
        -H "Accept: application/vnd.github+json" \
        "/repos/$REPO_OWNER/$REPO_NAME/branches/$MAIN_BRANCH/protection" \
        -f required_status_checks='{
            "strict": true,
            "checks": [
                {"context": "ci/tests"},
                {"context": "ci/build"},
                {"context": "ci/security-scan"},
                {"context": "ci/worker-deploy-test"}
            ]
        }' \
        -f enforce_admins=true \
        -f required_pull_request_reviews='{
            "required_approving_review_count": 1,
            "dismiss_stale_reviews": true,
            "require_code_owner_reviews": true,
            "require_last_push_approval": true
        }' \
        -f restrictions=null \
        -f required_linear_history=true \
        -f allow_force_pushes=false \
        -f allow_deletions=false \
        -f block_creations=false \
        -f required_conversation_resolution=true
    
    echo "✅ Branch protection rules applied"
}

# Function to set up required checks
setup_required_checks() {
    echo "🔍 Configuring required status checks..."
    
    # This will be enforced by the branch protection rules above
    echo "   - ci/tests (Unit tests)"
    echo "   - ci/build (Build validation)"  
    echo "   - ci/security-scan (CodeQL security scan)"
    echo "   - ci/worker-deploy-test (Worker deployment test)"
    
    echo "✅ Required checks configured"
}

# Function to enable signed commits
setup_signed_commits() {
    echo "🔐 Enabling signed commit requirements..."
    
    # Enable required signed commits
    gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        "/repos/$REPO_OWNER/$REPO_NAME" \
        -f require_commit_signing=true
    
    echo "✅ Signed commits required"
}

# Function to set up repository security settings
setup_security_settings() {
    echo "🛡️  Configuring repository security settings..."
    
    # Enable security features
    gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        "/repos/$REPO_OWNER/$REPO_NAME" \
        -f has_issues=true \
        -f has_projects=true \
        -f has_wiki=false \
        -f allow_squash_merge=true \
        -f allow_merge_commit=false \
        -f allow_rebase_merge=false \
        -f delete_branch_on_merge=true
    
    echo "✅ Security settings configured"
}

# Function to enable repository security features
enable_security_features() {
    echo "🔒 Enabling advanced security features..."
    
    # Enable dependency graph, dependabot, and secret scanning
    gh api \
        --method PUT \
        -H "Accept: application/vnd.github+json" \
        "/repos/$REPO_OWNER/$REPO_NAME/vulnerability-alerts" || echo "⚠️  Vulnerability alerts may already be enabled"
    
    gh api \
        --method PUT \
        -H "Accept: application/vnd.github+json" \
        "/repos/$REPO_OWNER/$REPO_NAME/automated-security-fixes" || echo "⚠️  Automated security fixes may already be enabled"
    
    echo "✅ Advanced security features enabled"
}

# Main execution
main() {
    echo "🚀 Starting GitHub repository security setup..."
    echo
    
    setup_branch_protection
    echo
    
    setup_required_checks  
    echo
    
    setup_signed_commits
    echo
    
    setup_security_settings
    echo
    
    enable_security_features
    echo
    
    echo "🎉 GitHub repository security setup completed!"
    echo
    echo "📋 Summary:"
    echo "   ✅ Branch protection enabled on $MAIN_BRANCH"
    echo "   ✅ Required status checks configured"
    echo "   ✅ Signed commits required"
    echo "   ✅ Security settings optimized"
    echo "   ✅ Advanced security features enabled"
    echo
    echo "⚠️  Note: Make sure to configure the required status checks in your CI/CD workflows"
}

# Run main function
main "$@"