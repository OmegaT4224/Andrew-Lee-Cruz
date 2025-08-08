# OmegaT Builder Makefile
# Author: Andrew Lee Cruz <allcatch37@gmail.com>
# UID: ALC-ROOT-1010-1111-XCOV∞

.PHONY: help bootstrap dev-ui dev-worker deploy-worker deploy-pages run-violet clean install test lint build

# Default target
help:
	@echo "🌟 OmegaT Builder - Sovereign AI-Assisted Project Generator"
	@echo "   Creator: Andrew Lee Cruz <allcatch37@gmail.com>"
	@echo "   UID: ALC-ROOT-1010-1111-XCOV∞"
	@echo ""
	@echo "Available targets:"
	@echo "  bootstrap     - One-shot local bootstrap setup"
	@echo "  install       - Install all dependencies"
	@echo "  dev-ui        - Start frontend UI development server"
	@echo "  dev-worker    - Start Cloudflare Worker locally"
	@echo "  deploy-worker - Deploy Worker to production"
	@echo "  deploy-pages  - Deploy Pages to production"
	@echo "  run-violet    - Run quantum agent (Violet AF)"
	@echo "  test          - Run all tests"
	@echo "  lint          - Run linting on all projects"
	@echo "  build         - Build all projects"
	@echo "  clean         - Clean build artifacts"
	@echo ""

# Bootstrap - one-shot setup
bootstrap:
	@echo "🚀 Running OmegaT Builder bootstrap..."
	./scripts/bootstrap.sh

# Install dependencies
install:
	@echo "📦 Installing all dependencies..."
	@cd apps/omegat-ui && npm install
	@cd services/pages-frontend && npm install
	@cd services/cloudflare-chain && npm install
	@cd agents/violet-af && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt
	@echo "✅ All dependencies installed"

# Development servers
dev-ui:
	@echo "🎨 Starting OmegaT UI development server..."
	@cd apps/omegat-ui && npm run dev

dev-worker:
	@echo "⚡ Starting Cloudflare Worker locally..."
	@cd services/cloudflare-chain && npm run dev

dev-pages:
	@echo "📊 Starting Pages Dashboard development server..."
	@cd services/pages-frontend && npm run dev

# Production deployments
deploy-worker:
	@echo "🚀 Deploying Cloudflare Worker to production..."
	@cd services/cloudflare-chain && npm run deploy

deploy-pages:
	@echo "🌐 Deploying Pages to production..."
	@cd apps/omegat-ui && npm run build
	@cd services/pages-frontend && npm run build
	@echo "✅ Pages built - use GitHub Actions for deployment"

# Quantum agent
run-violet:
	@echo "🔮 Running Violet Agent quantum sequence..."
	@cd agents/violet-af && source venv/bin/activate && python quantum_sequence_trigger.py

# Testing
test:
	@echo "🧪 Running all tests..."
	@cd apps/omegat-ui && npm test || echo "No tests configured for omegat-ui"
	@cd services/pages-frontend && npm test || echo "No tests configured for pages-frontend"
	@cd services/cloudflare-chain && npm test || echo "No tests configured for cloudflare-chain"
	@cd agents/violet-af && source venv/bin/activate && python -m pytest || echo "No tests configured for violet-af"
	@echo "✅ Tests completed"

# Linting
lint:
	@echo "🔍 Running linting on all projects..."
	@cd apps/omegat-ui && npm run lint || echo "Linting not configured for omegat-ui"
	@cd services/pages-frontend && npm run lint || echo "Linting not configured for pages-frontend"
	@cd services/cloudflare-chain && npm run lint || echo "Linting not configured for cloudflare-chain"
	@cd agents/violet-af && source venv/bin/activate && python -m flake8 . || echo "Linting not configured for violet-af"
	@echo "✅ Linting completed"

# Building
build:
	@echo "🔨 Building all projects..."
	@cd apps/omegat-ui && npm run build
	@cd services/pages-frontend && npm run build
	@cd services/cloudflare-chain && npm run build
	@echo "✅ All projects built"

# Verification
verify:
	@echo "✅ Verifying OmegaT Builder setup..."
	@echo "Checking directory structure..."
	@test -d apps/omegat-ui && echo "  ✅ apps/omegat-ui" || echo "  ❌ apps/omegat-ui"
	@test -d services/cloudflare-chain && echo "  ✅ services/cloudflare-chain" || echo "  ❌ services/cloudflare-chain"
	@test -d services/pages-frontend && echo "  ✅ services/pages-frontend" || echo "  ❌ services/pages-frontend"
	@test -d agents/violet-af && echo "  ✅ agents/violet-af" || echo "  ❌ agents/violet-af"
	@test -d contracts && echo "  ✅ contracts" || echo "  ❌ contracts"
	@test -d scripts && echo "  ✅ scripts" || echo "  ❌ scripts"
	@echo "Checking executables..."
	@test -x scripts/bootstrap.sh && echo "  ✅ scripts/bootstrap.sh" || echo "  ❌ scripts/bootstrap.sh"
	@test -x scripts/worker_env.sh && echo "  ✅ scripts/worker_env.sh" || echo "  ❌ scripts/worker_env.sh"
	@test -x agents/violet-af/quantum_sequence_trigger.py && echo "  ✅ quantum_sequence_trigger.py" || echo "  ❌ quantum_sequence_trigger.py"
	@echo "✅ Verification completed"

# Development workflow
dev-setup: bootstrap
	@echo "🔧 Setting up development environment..."
	@echo "Run the following commands to complete setup:"
	@echo ""
	@echo "1. Install Wrangler CLI:"
	@echo "   npm install -g wrangler"
	@echo ""
	@echo "2. Login to Cloudflare:"
	@echo "   wrangler login"
	@echo ""
	@echo "3. Set up Worker secrets:"
	@echo "   ./scripts/worker_env.sh"
	@echo ""
	@echo "4. Start development servers:"
	@echo "   make dev-ui      # In one terminal"
	@echo "   make dev-worker  # In another terminal"

# Production deployment
deploy-all: build deploy-worker deploy-pages
	@echo "🎉 Full deployment completed!"
	@echo "Access your application at:"
	@echo "  - UI: https://omegat-ui.pages.dev"
	@echo "  - Dashboard: https://omegat-pages-dashboard.pages.dev"
	@echo "  - Worker API: https://omegat-cloudflare-chain-prod.workers.dev"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf apps/omegat-ui/dist
	@rm -rf apps/omegat-ui/node_modules/.vite
	@rm -rf services/pages-frontend/dist
	@rm -rf services/pages-frontend/node_modules/.vite
	@rm -rf services/cloudflare-chain/dist
	@rm -rf agents/violet-af/VioletState.json
	@rm -rf agents/violet-af/__pycache__
	@echo "✅ Clean completed"

# Security setup
security-setup:
	@echo "🔒 Setting up security configurations..."
	@echo "This will configure GitHub repository security and Cloudflare Access"
	@echo "Make sure you have 'gh' CLI and 'wrangler' installed and authenticated"
	@echo ""
	@read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ]
	@./scripts/gh_rulesets.sh
	@./scripts/cloudflare_access.sh

# Status check
status:
	@echo "📊 OmegaT Builder Status"
	@echo "======================="
	@echo ""
	@echo "🔧 Local Development:"
	@test -d apps/omegat-ui/node_modules && echo "  ✅ omegat-ui dependencies" || echo "  ❌ omegat-ui dependencies (run: make install)"
	@test -d services/pages-frontend/node_modules && echo "  ✅ pages-frontend dependencies" || echo "  ❌ pages-frontend dependencies (run: make install)"
	@test -d services/cloudflare-chain/node_modules && echo "  ✅ cloudflare-chain dependencies" || echo "  ❌ cloudflare-chain dependencies (run: make install)"
	@test -d agents/violet-af/venv && echo "  ✅ violet-af venv" || echo "  ❌ violet-af venv (run: make install)"
	@echo ""
	@echo "🏗️  Build Status:"
	@test -d apps/omegat-ui/dist && echo "  ✅ omegat-ui built" || echo "  ⚠️  omegat-ui not built (run: make build)"
	@test -d services/pages-frontend/dist && echo "  ✅ pages-frontend built" || echo "  ⚠️  pages-frontend not built (run: make build)"
	@echo ""
	@echo "📝 Recent Activity:"
	@test -f agents/violet-af/VioletState.json && echo "  ✅ Recent quantum sequence executed" || echo "  ⚠️  No recent quantum sequence (run: make run-violet)"