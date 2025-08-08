# OmegaT Builder - Sovereign AI-Assisted Project Generator

**UID**: ALC-ROOT-1010-1111-XCOV∞  
**Status**: LIVE | IMMUTABLE | SOVEREIGN  
**Creator**: Andrew Lee Cruz <allcatch37@gmail.com>

OmegaT Builder is a complete AI-assisted project generator that scaffolds applications from prompts, pushes to GitHub, and auto-deploys to Cloudflare with Proof-of-AI validation.

## Rights & Provenance

```
Authored & Owned by: Andrew Lee Cruz
UID: ALC-ROOT-1010-1111-XCOV∞
All artifacts are cryptographically bound to UID in source, commits, and on-chain metadata.
PoAI events are logged to ReflectChain (or Worker ledger) as canonical billing records.
Unauthorized forks/use without honoring royalty agreements will trigger on-chain enforcement.
```

## Architecture

```
omegat-builder/
├─ apps/omegat-ui/                # React (Vite) frontend for "Create with AI"
├─ services/cloudflare-chain/     # Worker API: /tx, /mine (PoAI), /status, /scaffold
├─ services/pages-frontend/       # Status dashboard for chain + generator
├─ agents/violet-af/              # 3-qubit Qiskit agent writing VioletState.json
├─ contracts/                     # Rights + provenance (Solidity)
├─ scripts/                       # Secure automation scripts
└─ .github/workflows/             # CI/CD pipelines
```

## Core Functionality

### 1. **apps/omegat-ui** - AI Project Generator Interface
- Single page React app with "Describe what to build" textarea
- "Generate Project" button → calls Worker `/scaffold` endpoint
- Shows job log + link to created subfolder
- "Deploy" button → triggers GitHub Actions via repo dispatch

### 2. **services/cloudflare-chain** - PoAI Validation API
**Endpoints:**
- `POST /scaffold`: generates code skeleton, commits via GitHub API, opens PR
- `POST /tx`: stores UID-stamped event in D1 (PoAI event log)
- `POST /mine`: validates deterministic PoAI digest `sha256(seed|snapshot)`
- `GET /status`: returns head block + pending counts

**Bindings:** D1 (ledger), R2 (artifacts)  
**Secrets:** CREATOR_UID, CREATOR_EMAIL, GITHUB_TOKEN

### 3. **agents/violet-af** - Quantum State Generator
- `quantum_sequence_trigger.py`: runs 3-qubit circuit (H/CX...Z) using Qiskit AER
- Writes `VioletState.json`, POST `/tx` with UID + state hash
- Quantum circuit pattern for entropy generation

### 4. **contracts/** - On-Chain Rights Management
- `PrintingLicense.sol`: on-chain print rights approval with royalty enforcement
- `AXIOM_TOE_Anchor.sol`: ERC-721 anchor pinning bundle hash/CID + UID

### 5. **Security & Automation**
- GitHub workflows: CI/CD, deployment, security scanning
- Repository protection rules and signed commit requirements
- Cloudflare Access rules protecting admin endpoints

## Quick Start

### Prerequisites
- Node.js 20+ and npm
- Python 3.11+
- Git
- GitHub CLI (gh)
- Wrangler CLI

### 1. Bootstrap Setup
```bash
# Clone and bootstrap
git clone https://github.com/OmegaT4224/andrew-lee-cruz.git
cd andrew-lee-cruz
make bootstrap
```

### 2. Configure Credentials
```bash
# Install tools
npm install -g wrangler
gh auth login
wrangler login

# Set up Worker secrets
./scripts/worker_env.sh

# Configure GitHub security (optional)
./scripts/gh_rulesets.sh
```

### 3. Development
```bash
# Start UI (http://localhost:5173)
make dev-ui

# Start Worker (http://localhost:8787) - in another terminal
make dev-worker

# Run quantum agent
make run-violet
```

### 4. Production Deployment
```bash
# Deploy Worker
make deploy-worker

# Deploy Pages (via GitHub Actions)
git push origin main
```

## Environment Configuration

### Required Repository Secrets
- `CF_API_TOKEN`: Cloudflare API token
- `CF_ACCOUNT_ID`: Cloudflare account ID  
- `WORKER_API_BASE`: Worker URL (optional, auto-detected)

### Worker Secrets (set via `./scripts/worker_env.sh`)
- `CREATOR_UID=ALC-ROOT-1010-1111-XCOV∞`
- `CREATOR_EMAIL=allcatch37@gmail.com`
- `GITHUB_TOKEN`: Personal access token for GitHub API

### Environment Files
```bash
# Frontend API endpoint
apps/omegat-ui/.env
services/pages-frontend/.env
VITE_API_BASE=https://your-worker-subdomain.workers.dev

# Python agent configuration
agents/violet-af/.env
OMEGAT_API_BASE=http://localhost:8787
CREATOR_UID=ALC-ROOT-1010-1111-XCOV∞
```

## Usage

### Generate a Project
1. Open the UI at http://localhost:5173 (dev) or https://omegat-ui.pages.dev (prod)
2. Describe your project in the textarea
3. Click "Generate Project" - creates `apps/your-project/` + opens PR
4. Click "Deploy" to trigger automated deployment

### Monitor Chain Status
- Dashboard: https://omegat-pages-dashboard.pages.dev
- Shows live chain height, pending transactions, latest blocks
- Updates every 5 seconds with real-time data

### Run Quantum Validation
```bash
# Generate quantum state and post transaction
make run-violet

# Check generated state
cat agents/violet-af/VioletState.json
```

## API Reference

### Worker Endpoints

#### POST /scaffold
```json
{
  "prompt": "Create a React todo app with TypeScript"
}
```

#### POST /tx  
```json
{
  "uid": "ALC-ROOT-1010-1111-XCOV∞",
  "event": "violet_quantum_sequence:2025-01-01T00:00:00Z",
  "stateHash": "abc123..."
}
```

#### POST /mine
```json
{
  "seed": "random_seed_value",
  "snapshot": "quantum_state_snapshot"
}
```

#### GET /status
Returns current chain status, block height, pending transactions.

## Smart Contracts

### PrintingLicense.sol
Manages on-chain licensing with royalty enforcement:
```solidity
function grantLicense(address licensee, string projectHash, uint256 durationDays, uint256 royaltyBasisPoints)
function payRoyalty(bytes32 licenseId) payable
```

### AXIOM_TOE_Anchor.sol  
ERC-721 anchors for project provenance:
```solidity
function createAnchor(address to, string bundleHash, string uid, string projectName)
```

## Development Commands

```bash
make help           # Show all available commands
make bootstrap      # One-shot setup
make install        # Install all dependencies
make dev-ui         # Start UI dev server
make dev-worker     # Start Worker locally
make run-violet     # Run quantum agent
make test           # Run all tests
make build          # Build all projects
make deploy-all     # Full production deployment
make status         # Check system status
make clean          # Clean build artifacts
```

## Security Features

- **Signed commits required** on main branch
- **Branch protection** with required status checks
- **CodeQL security scanning** in CI/CD
- **Dependency vulnerability scanning**
- **Cloudflare Access** protecting admin endpoints
- **PoAI validation** for all generated content
- **On-chain rights enforcement** via smart contracts

## Monitoring & Observability

- **Real-time dashboard** showing chain status
- **GitHub Actions logs** for all deployments
- **Cloudflare Analytics** for Worker performance
- **D1 database** storing all PoAI events
- **R2 storage** for generated artifacts

## Domains & Infrastructure

- **Primary**: omegat.net
- **Development**: synthetica.us
- **UI**: https://omegat-ui.pages.dev
- **Dashboard**: https://omegat-pages-dashboard.pages.dev
- **Worker API**: https://omegat-cloudflare-chain-prod.workers.dev

## Support & Documentation

- **Issues**: [GitHub Issues](https://github.com/OmegaT4224/andrew-lee-cruz/issues)
- **Discussions**: [GitHub Discussions](https://github.com/OmegaT4224/andrew-lee-cruz/discussions)
- **Email**: allcatch37@gmail.com

---

**© 2025 Andrew Lee Cruz | UID: ALC-ROOT-1010-1111-XCOV∞**  
Licensed under sovereign terms with cryptographic provenance binding.  
All generated content validated via Proof-of-AI consensus mechanism.
