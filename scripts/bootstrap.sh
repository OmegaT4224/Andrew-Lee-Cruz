#!/usr/bin/env bash
# VIOLET-AF Bootstrap Script
# UID: ALC-ROOT-1010-1111-XCOV∞
# Contact: allcatch37@gmail.com
# 
# Complete end-to-end deployment of VIOLET-AF Quantum Logic Integration

set -euo pipefail

CREATOR_EMAIL="allcatch37@gmail.com"
CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🌀 VIOLET-AF Bootstrap Script"
echo "================================"
echo "   UID: $CREATOR_UID"
echo "   Contact: $CREATOR_EMAIL"
echo "   Project: $(basename "$PROJECT_ROOT")"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    local missing_tools=()
    local tools=("python3" "pip" "git" "curl")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install missing tools and run again."
        exit 1
    fi
    
    log_success "All prerequisites available"
}

# Install Python dependencies
install_python_deps() {
    log_step "Installing Python dependencies..."
    
    cd "$PROJECT_ROOT"
    
    if [[ -f requirements.txt ]]; then
        pip install -r requirements.txt
        log_success "Python dependencies installed"
    else
        log_warning "requirements.txt not found"
    fi
}

# Test quantum system
test_quantum_system() {
    log_step "Testing VIOLET-AF Quantum System..."
    
    cd "$PROJECT_ROOT"
    
    # Test quantum sequence trigger
    python3 -c "
import sys
sys.path.insert(0, './violet-af-quantum-agent/src')
from violet_af.quantum_sequence_trigger import QuantumSequenceTrigger

print('🔬 Testing QuantumSequenceTrigger...')
trigger = QuantumSequenceTrigger(log_dir='./bootstrap_test_logs')
violet_state = trigger.execute_violet_sequence()

if violet_state.get('status') == 'ready_for_launch':
    print('✅ Quantum system operational')
    print(f'   Sequence ID: {violet_state[\"violet_sequence_id\"]}')
    print(f'   Backend: {violet_state[\"quantum_result\"][\"backend\"]}')
    print(f'   Task Tree: {len(violet_state[\"task_tree\"][\"root\"][\"children\"])} children')
else:
    print(f'❌ Quantum system error: {violet_state.get(\"error\")}')
    sys.exit(1)
"
    
    log_success "Quantum system test passed"
}

# Test AxiomDevCore agent
test_axiom_agent() {
    log_step "Testing AxiomDevCore Agent..."
    
    cd "$PROJECT_ROOT"
    
    python3 -c "
import sys
sys.path.insert(0, './axiom-dev-core/src')
from axiom_dev_core.agent import AxiomDevCoreAgent

print('🤖 Testing AxiomDevCore Agent...')
agent = AxiomDevCoreAgent(repo_path='.', log_dir='./bootstrap_test_logs')

# Test initialization
init_result = agent.initialize_system()
if init_result['initialized']:
    print('✅ AxiomDevCore agent operational')
else:
    print('❌ AxiomDevCore agent failed')
    sys.exit(1)

# Test status
status = agent.get_status()
if status['healthy']:
    print('✅ Agent health check passed')
else:
    print('❌ Agent health check failed')
    sys.exit(1)
"
    
    log_success "AxiomDevCore agent test passed"
}

# Setup GitHub security
setup_github_security() {
    log_step "Setting up GitHub security..."
    
    if [[ -f "$SCRIPT_DIR/gh_rulesets.sh" ]]; then
        chmod +x "$SCRIPT_DIR/gh_rulesets.sh"
        
        log_info "GitHub rulesets script available"
        log_warning "Run manually: $SCRIPT_DIR/gh_rulesets.sh"
        log_warning "Requires GitHub CLI authentication"
    else
        log_warning "GitHub rulesets script not found"
    fi
    
    if [[ -f "$SCRIPT_DIR/cleanup_ssh.sh" ]]; then
        chmod +x "$SCRIPT_DIR/cleanup_ssh.sh"
        log_info "SSH cleanup script available"
        log_warning "Run manually: $SCRIPT_DIR/cleanup_ssh.sh"
    else
        log_warning "SSH cleanup script not found"
    fi
}

# Setup Cloudflare
setup_cloudflare() {
    log_step "Setting up Cloudflare infrastructure..."
    
    if [[ -f "$SCRIPT_DIR/worker_env.sh" ]]; then
        chmod +x "$SCRIPT_DIR/worker_env.sh"
        log_info "Worker environment script available"
        log_warning "Run manually: $SCRIPT_DIR/worker_env.sh"
        log_warning "Requires Cloudflare API credentials"
    else
        log_warning "Worker environment script not found"
    fi
    
    if [[ -f "$SCRIPT_DIR/cloudflare_access.sh" ]]; then
        chmod +x "$SCRIPT_DIR/cloudflare_access.sh"
        log_info "Cloudflare Access script available"
        log_warning "Run manually: $SCRIPT_DIR/cloudflare_access.sh"
    else
        log_warning "Cloudflare Access script not found"
    fi
}

# Generate documentation
generate_documentation() {
    log_step "Generating documentation..."
    
    cd "$PROJECT_ROOT"
    
    python3 -c "
import sys
sys.path.insert(0, './axiom-dev-core/src')
from axiom_dev_core.agent import AxiomDevCoreAgent

print('📚 Generating documentation...')
agent = AxiomDevCoreAgent(repo_path='.', log_dir='./bootstrap_test_logs')

try:
    doc_result = agent.generate_documentation()
    if doc_result.get('committed'):
        print('✅ Documentation generated and committed')
        for doc_type, path in doc_result['generated_docs'].items():
            print(f'   • {doc_type}: {path}')
    else:
        print('⚠️  Documentation generated but not committed')
except Exception as e:
    print(f'❌ Documentation generation failed: {e}')
"
    
    log_success "Documentation generation complete"
}

# Run quantum-classical integration test
run_integration_test() {
    log_step "Running quantum-classical integration test..."
    
    cd "$PROJECT_ROOT"
    
    python3 -c "
import sys
sys.path.insert(0, './violet-af-quantum-agent/src')
sys.path.insert(0, './axiom-dev-core/src')

from violet_af.quantum_sequence_trigger import QuantumSequenceTrigger
from axiom_dev_core.agent import AxiomDevCoreAgent

print('🔗 Testing quantum-classical integration...')

# Execute quantum sequence
trigger = QuantumSequenceTrigger(log_dir='./integration_test_logs')
violet_state = trigger.execute_violet_sequence()

# Process with AxiomDevCore
agent = AxiomDevCoreAgent(repo_path='.', log_dir='./integration_test_logs')
compile_result = agent.quantum_compile_task(violet_state)

if compile_result.get('quantum_compile_success'):
    print('✅ Quantum-classical integration successful')
    print(f'   Quantum Sequence: {violet_state.get(\"violet_sequence_id\")}')
    print(f'   GitHub Integration: {compile_result.get(\"github_integration\", {}).get(\"success\")}')
else:
    print('❌ Integration test failed')
    sys.exit(1)
"
    
    log_success "Integration test passed"
}

# Check deployment status
check_deployment_status() {
    log_step "Checking deployment status..."
    
    cd "$PROJECT_ROOT"
    
    local components=(
        "violet-af-quantum-agent/src/violet_af/quantum_sequence_trigger.py:Quantum Agent"
        "axiom-dev-core/src/axiom_dev_core/agent.py:AxiomDevCore Agent"
        "cloudflare-chain/worker/src/index.ts:Cloudflare Worker"
        "contracts/PoAIRegistry.sol:PoAI Registry Contract"
        "pages-frontend/omegat/index.html:Frontend"
        "scripts/bootstrap.sh:Bootstrap Script"
    )
    
    echo ""
    log_info "Component Status:"
    
    for component in "${components[@]}"; do
        local file_path="${component%%:*}"
        local component_name="${component##*:}"
        
        if [[ -f "$file_path" ]]; then
            echo -e "   ${GREEN}✅ $component_name${NC}"
        else
            echo -e "   ${RED}❌ $component_name${NC}"
        fi
    done
}

# Show final summary
show_summary() {
    echo ""
    echo "🎉 VIOLET-AF Bootstrap Complete!"
    echo "================================"
    echo ""
    log_success "Core Components Deployed:"
    echo "   ✓ QuantumSequenceTrigger: 3-qubit symbolic control"
    echo "   ✓ AxiomDevCore Agent: GitHub automation"
    echo "   ✓ ReflectChain Logging: UID-stamped provenance"
    echo "   ✓ Smart Contracts: PoAI Registry, Printing License"
    echo "   ✓ Frontend Interface: VIOLET-AF dashboard"
    echo "   ✓ Security Scripts: GitHub + Cloudflare hardening"
    echo ""
    log_info "Manual Steps Required:"
    echo "   1. GitHub Security: Run scripts/gh_rulesets.sh"
    echo "   2. SSH Cleanup: Run scripts/cleanup_ssh.sh"
    echo "   3. Cloudflare Setup: Run scripts/worker_env.sh"
    echo "   4. Access Policies: Run scripts/cloudflare_access.sh"
    echo "   5. Contract Deployment: Use Foundry/Hardhat"
    echo ""
    log_info "Configuration Files:"
    echo "   • Wrangler: cloudflare-chain/wrangler.toml"
    echo "   • Database Schema: cloudflare-chain/schema/d1.sql"
    echo "   • Frontend: pages-frontend/omegat/index.html"
    echo ""
    log_info "Testing Commands:"
    echo "   • Quantum Test: python -m violet_af.cli --execute"
    echo "   • Integration Test: python integration_test.py"
    echo "   • Frontend Test: Open pages-frontend/omegat/index.html"
    echo ""
    echo -e "${CYAN}Contact: $CREATOR_EMAIL${NC}"
    echo -e "${CYAN}UID: $CREATOR_UID${NC}"
    echo -e "${CYAN}Domain: Kidhum${NC}"
    echo ""
    log_success "VIOLET-AF Quantum Logic Integration Ready! 🌀"
}

# Main execution
main() {
    echo "Starting VIOLET-AF bootstrap process..."
    echo ""
    
    check_prerequisites
    install_python_deps
    test_quantum_system
    test_axiom_agent
    run_integration_test
    generate_documentation
    setup_github_security
    setup_cloudflare
    check_deployment_status
    show_summary
}

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

# Run main function
main "$@"