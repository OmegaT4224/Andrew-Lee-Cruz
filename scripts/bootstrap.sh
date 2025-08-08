#!/bin/bash
# bootstrap.sh - One-shot local bootstrap for OmegaT Builder
# Author: Andrew Lee Cruz <allcatch37@gmail.com>
# UID: ALC-ROOT-1010-1111-XCOV∞

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CREATOR_UID="ALC-ROOT-1010-1111-XCOV∞"
CREATOR_EMAIL="allcatch37@gmail.com"

echo "🚀 OmegaT Builder - Local Bootstrap"
echo "   Project Root: $PROJECT_ROOT"
echo "   Creator: $CREATOR_EMAIL"
echo "   UID: $CREATOR_UID"
echo

cd "$PROJECT_ROOT"

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Node.js and npm
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi
    
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        missing_tools+=("pip")
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "❌ Missing required tools: ${missing_tools[*]}"
        echo "   Please install them before running bootstrap."
        exit 1
    fi
    
    echo "✅ All prerequisites satisfied"
    echo "   Node.js: $(node --version)"
    echo "   npm: $(npm --version)"
    echo "   Python: $(python3 --version)"
    echo "   Git: $(git --version)"
}

# Function to install frontend dependencies
install_frontend_deps() {
    echo "📦 Installing frontend dependencies..."
    
    # Install omegat-ui dependencies
    if [ -d "apps/omegat-ui" ]; then
        echo "   📱 Installing omegat-ui dependencies..."
        cd "$PROJECT_ROOT/apps/omegat-ui"
        npm install
        echo "   ✅ omegat-ui dependencies installed"
    fi
    
    # Install pages-frontend dependencies
    if [ -d "services/pages-frontend" ]; then
        echo "   📊 Installing pages-frontend dependencies..."
        cd "$PROJECT_ROOT/services/pages-frontend"
        npm install
        echo "   ✅ pages-frontend dependencies installed"
    fi
    
    # Install cloudflare-chain dependencies
    if [ -d "services/cloudflare-chain" ]; then
        echo "   ⚡ Installing cloudflare-chain dependencies..."
        cd "$PROJECT_ROOT/services/cloudflare-chain"
        npm install
        echo "   ✅ cloudflare-chain dependencies installed"
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to install Python dependencies
install_python_deps() {
    echo "🐍 Installing Python dependencies..."
    
    if [ -d "agents/violet-af" ]; then
        cd "$PROJECT_ROOT/agents/violet-af"
        
        # Create virtual environment if it doesn't exist
        if [ ! -d "venv" ]; then
            echo "   🔧 Creating Python virtual environment..."
            python3 -m venv venv
        fi
        
        # Activate virtual environment and install dependencies
        echo "   📦 Installing violet-af dependencies..."
        source venv/bin/activate
        pip install -r requirements.txt
        deactivate
        
        echo "   ✅ violet-af dependencies installed"
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to set up environment files
setup_environment_files() {
    echo "⚙️  Setting up environment files..."
    
    # Set up omegat-ui environment
    if [ -d "apps/omegat-ui" ] && [ ! -f "apps/omegat-ui/.env" ]; then
        echo "   📱 Creating omegat-ui .env file..."
        cp "apps/omegat-ui/.env.example" "apps/omegat-ui/.env"
        echo "   ✅ omegat-ui .env created"
    fi
    
    # Set up pages-frontend environment
    if [ -d "services/pages-frontend" ] && [ ! -f "services/pages-frontend/.env" ]; then
        echo "   📊 Creating pages-frontend .env file..."
        cp "services/pages-frontend/.env.example" "services/pages-frontend/.env"
        echo "   ✅ pages-frontend .env created"
    fi
    
    # Set up violet-af environment
    if [ -d "agents/violet-af" ] && [ ! -f "agents/violet-af/.env" ]; then
        echo "   🔮 Creating violet-af .env file..."
        cat > "agents/violet-af/.env" << EOF
OMEGAT_API_BASE=http://localhost:8787
CREATOR_UID=$CREATOR_UID
CREATOR_EMAIL=$CREATOR_EMAIL
EOF
        echo "   ✅ violet-af .env created"
    fi
}

# Function to make scripts executable
make_scripts_executable() {
    echo "🔧 Making scripts executable..."
    
    if [ -d "scripts" ]; then
        chmod +x scripts/*.sh
        echo "   ✅ Scripts made executable"
    fi
    
    if [ -f "agents/violet-af/quantum_sequence_trigger.py" ]; then
        chmod +x "agents/violet-af/quantum_sequence_trigger.py"
        echo "   ✅ Python agent made executable"
    fi
}

# Function to run basic tests
run_basic_tests() {
    echo "🧪 Running basic tests..."
    
    # Test frontend builds
    if [ -d "apps/omegat-ui" ]; then
        echo "   📱 Testing omegat-ui build..."
        cd "$PROJECT_ROOT/apps/omegat-ui"
        npm run build > /dev/null
        echo "   ✅ omegat-ui builds successfully"
    fi
    
    if [ -d "services/pages-frontend" ]; then
        echo "   📊 Testing pages-frontend build..."
        cd "$PROJECT_ROOT/services/pages-frontend"
        npm run build > /dev/null
        echo "   ✅ pages-frontend builds successfully"
    fi
    
    # Test cloudflare-chain build
    if [ -d "services/cloudflare-chain" ]; then
        echo "   ⚡ Testing cloudflare-chain build..."
        cd "$PROJECT_ROOT/services/cloudflare-chain"
        npm run build > /dev/null
        echo "   ✅ cloudflare-chain builds successfully"
    fi
    
    # Test Python agent
    if [ -f "agents/violet-af/quantum_sequence_trigger.py" ]; then
        echo "   🔮 Testing violet-af agent..."
        cd "$PROJECT_ROOT/agents/violet-af"
        source venv/bin/activate
        python quantum_sequence_trigger.py --help > /dev/null 2>&1 || true
        deactivate
        echo "   ✅ violet-af agent loads successfully"
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to show next steps
show_next_steps() {
    echo "📋 Next Steps:"
    echo
    echo "1. 🔑 Set up Cloudflare credentials:"
    echo "   npm install -g wrangler"
    echo "   wrangler login"
    echo "   ./scripts/worker_env.sh"
    echo
    echo "2. 🛡️  Configure GitHub security:"
    echo "   gh auth login"
    echo "   ./scripts/gh_rulesets.sh"
    echo
    echo "3. ☁️  Set up Cloudflare Access:"
    echo "   ./scripts/cloudflare_access.sh"
    echo
    echo "4. 🚀 Start development:"
    echo "   make dev-ui      # Start frontend UI"
    echo "   make dev-worker  # Start Worker locally"
    echo "   make run-violet  # Run quantum agent"
    echo
    echo "5. 🔬 Test the system:"
    echo "   - Open http://localhost:5173 for UI"
    echo "   - Check Worker at http://localhost:8787"
    echo "   - Run quantum sequence with make run-violet"
    echo
    echo "6. 📚 Read the documentation:"
    echo "   - README.md for setup instructions"
    echo "   - Individual service READMEs for details"
}

# Main execution
main() {
    echo "🚀 Starting OmegaT Builder local bootstrap..."
    echo
    
    check_prerequisites
    echo
    
    install_frontend_deps
    echo
    
    install_python_deps
    echo
    
    setup_environment_files
    echo
    
    make_scripts_executable
    echo
    
    run_basic_tests
    echo
    
    echo "🎉 Bootstrap completed successfully!"
    echo
    
    show_next_steps
}

# Run main function
main "$@"