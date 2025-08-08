# VIOLET-AF: Autonomous Quantum Logic Initialization & PoAI Stack

**UID**: ALC-ROOT-1010-1111-XCOV∞  
**Author**: Andrew Lee Cruz  
**ORCID**: 0009-0000-3695-1084  
**License**: UCL-∞  
**Status**: PRODUCTION-READY | QUANTUM-ENHANCED | ENERGY-AWARE

> **All works in this repository are authored and owned by Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞, ORCID: 0009-0000-3695-1084) and governed by the Universal Creator License (UCL-∞). Printing and derivative rights are enforced on-chain via PrintingLicense.sol and AXIOM_TOE_Anchor.sol.**

## Overview

VIOLET-AF is a complete production-ready Proof-of-AI blockchain ecosystem that replaces traditional mining with verifiable AI computation proofs. The system is mobile-first, energy-efficient, and integrates quantum-inspired symbolic processing.

### Key Features

- 🔮 **Quantum-Enhanced PoAI**: Qiskit-powered quantum computations with UID stamping
- 📱 **Mobile-First Validators**: Android/iOS apps with hardware-backed ED25519 signing
- ⚡ **Energy-Aware Policy**: Only runs when charging >70% battery, screen off, CPU cool
- ☁️ **Serverless Architecture**: Cloudflare Workers with D1/R2 storage
- 🛡️ **Hardware Security**: StrongBox/Keystore integration with Play Integrity attestation
- 🌐 **Real-Time Dashboard**: Live monitoring with WebSocket updates
- 🧪 **Development Simulator**: Complete testing environment for PoAI computations
- 🤖 **GitHub Automation**: Automated content generation and repository management

## Architecture

### Core Components

1. **Mobile Light-Validator** - Android/iOS apps with energy-aware PoAI computation
2. **Cloudflare Worker Chain** - Serverless blockchain backend with D1/R2 storage
3. **Smart Contracts** - Solidity contracts for PoAI registry and content anchoring
4. **Frontend Dashboard** - React/Vite real-time monitoring interface
5. **PoAI Simulator** - FastAPI development and testing environment
6. **VIOLET-AF Quantum Engine** - Qiskit-based quantum circuit processing
7. **AxiomDevCore** - GitHub automation and content generation

### Energy Policy

The system implements a strict energy-aware policy:
- **Battery**: Charging OR >70% charge level
- **Screen**: Must be off during computation
- **Temperature**: CPU <45°C
- **Network**: Efficient WebSocket communication
- **Clean Energy**: Grid carbon API integration (where available)

### PoAI Format

- **UID**: `ALC-ROOT-1010-1111-XCOV∞`
- **Digest**: SHA256(payload + "|" + UID + "|" + timestamp)
- **Signature**: ED25519 with hardware-backed keys
- **Attestation**: Play Integrity token validation
- **Quantum Influence**: Statevector hash integration

## Quick Start

### Prerequisites

- **Node.js** 18+ (for frontend and Cloudflare Workers)
- **Python** 3.10+ (for quantum engine and simulator)
- **Android Studio** (for mobile development)
- **Cloudflare Account** (for Worker deployment)
- **GitHub CLI** (for automation setup)

### 1. Clone and Setup

```bash
git clone https://github.com/OmegaT4224/Andrew-Lee-Cruz.git
cd Andrew-Lee-Cruz

# Install Python dependencies
pip install -r requirements.txt
pip install -r poai-sim/requirements.txt

# Install frontend dependencies
cd pages-frontend
npm install
cd ..
```

### 2. Start Development Environment

```bash
# Start PoAI Simulator
cd poai-sim
python server.py &
echo "🧪 Simulator running at http://localhost:8000"

# Start Frontend Dashboard (in new terminal)
cd pages-frontend
npm run dev &
echo "📊 Dashboard running at http://localhost:3000"

# Test Quantum Engine
cd violet-af
python quantum_engine.py
echo "🔮 Quantum engine test complete"
```

### 3. Test the Stack

```bash
# Test simulator API
curl http://localhost:8000/api/status

# Test device simulation
curl -X POST http://localhost:8000/api/poai/submit \
  -H "Content-Type: application/json" \
  -d '{"device_id":"SIM_GALAXY_S24_001","input_data":"test","force_computation":true}'

# View real-time dashboard
open http://localhost:3000
```

## Component Setup

### Mobile Light-Validator (Android)

1. **Prerequisites**:
   - Android Studio Arctic Fox+
   - Android SDK API 24+ (Android 7.0+)
   - Device with StrongBox support (recommended)

2. **Setup**:
   ```bash
   # Navigate to Android project
   cd mobile/android
   
   # Build debug APK
   ./gradlew assembleDebug
   
   # Install on device
   adb install app/build/outputs/apk/debug/app-debug.apk
   ```

3. **Configuration**:
   - Enable Developer Options
   - Allow USB Debugging
   - Configure energy settings for background operation

### Cloudflare Worker Chain

1. **Setup Cloudflare CLI**:
   ```bash
   npm install -g wrangler
   wrangler login
   ```

2. **Deploy Infrastructure**:
   ```bash
   # Use automated script
   ./scripts/worker_env.sh development
   
   # Or manually:
   cd cloudflare-chain
   wrangler d1 create cm_chain_db_dev
   wrangler d1 execute cm_chain_db_dev --file ./schema/d1.sql
   wrangler r2 bucket create cm-ledger-dev
   wrangler deploy --env development
   ```

3. **Set Environment Variables**:
   ```bash
   wrangler secret put POAI_API_KEY --env development
   # Enter your secure API key when prompted
   ```

### Frontend Dashboard

1. **Configuration**:
   ```bash
   cd pages-frontend
   cp .env.example .env.local
   
   # Edit .env.local with your Worker URL
   echo "VITE_WORKER_BASE_URL=https://your-worker.workers.dev" >> .env.local
   ```

2. **Development**:
   ```bash
   npm run dev  # Local development
   npm run build  # Production build
   ```

3. **Deployment**:
   ```bash
   npm run deploy  # Deploy to Cloudflare Pages
   ```

### Smart Contracts

1. **Setup Hardhat**:
   ```bash
   npm install -g hardhat
   cd contracts
   npm install
   ```

2. **Compile and Deploy**:
   ```bash
   npx hardhat compile
   npx hardhat run scripts/deploy.ts --network sepolia
   ```

3. **Verify Contracts**:
   ```bash
   npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
   ```

## Development Guide

### Testing PoAI Computations

1. **Start Simulator**:
   ```bash
   cd poai-sim
   python server.py
   ```

2. **Open Web Interface**:
   - Navigate to http://localhost:8000
   - Use device controls to simulate energy states
   - Submit test PoAI computations
   - Monitor real-time logs

3. **API Testing**:
   ```bash
   # Check device status
   curl http://localhost:8000/api/devices
   
   # Submit PoAI computation
   curl -X POST http://localhost:8000/api/poai/submit \
     -H "Content-Type: application/json" \
     -d '{
       "device_id": "SIM_GALAXY_S24_001",
       "input_data": "{\"test\":\"quantum_state\",\"uid\":\"ALC-ROOT-1010-1111-XCOV∞\"}",
       "force_computation": false
     }'
   ```

### Quantum Engine Development

1. **Basic Usage**:
   ```python
   from violet_af.quantum_engine import VioletQuantumEngine
   
   engine = VioletQuantumEngine()
   violet_state = engine.run_violet_computation(
       num_qubits=3,
       depth=4,
       shots=1024
   )
   
   print(f"Quantum UID: {violet_state.uid}")
   print(f"Entanglement: {violet_state.entanglement_measure}")
   ```

2. **Custom Circuits**:
   ```python
   circuit = engine.create_violet_circuit(num_qubits=4, depth=3)
   result = engine.execute_quantum_computation(circuit, shots=2048)
   violet_state = engine.create_violet_state(circuit, result)
   ```

### Automation with AxiomDevCore

1. **Content Generation**:
   ```python
   from violet_af.axiom_dev_core import AxiomDevCore
   
   core = AxiomDevCore(github_token="your_token")
   readme = core.content_writer.generate_readme(
       project_name="My VIOLET-AF Project",
       description="Quantum-enhanced application",
       features=["Energy-aware", "Quantum-powered", "Mobile-first"]
   )
   
   core.content_writer.save_content(readme, "README.md")
   ```

2. **Repository Automation**:
   ```python
   results = core.automate_repository_setup(
       repo="username/repository",
       project_config={
           "name": "VIOLET-AF Demo",
           "description": "Demonstration project",
           "features": ["Quantum computing", "Mobile validators"],
           "quantum_influenced": True
       }
   )
   ```

## Security & CI/CD

### Repository Security Setup

```bash
# Run automated security setup
./scripts/gh_rulesets.sh

# Manual security checks
gh auth login
gh repo view --json securityAndAnalysis
```

### CI/CD Pipeline

The repository includes comprehensive GitHub Actions workflows:

- **Security Scanning**: CodeQL, Trivy vulnerability scanner
- **Multi-Language Testing**: Python, TypeScript, Kotlin, Solidity
- **Integration Tests**: End-to-end API and quantum engine testing
- **Energy Policy Validation**: Automated policy compliance checks
- **License Compliance**: UCL-∞ verification and UID consistency
- **Automated Deployment**: Cloudflare Workers and Pages

### Branch Protection

- Required PR reviews (1+ approvers)
- Required status checks
- No force pushes or deletions
- Signed commits required
- Linear history enforced

## API Reference

### Cloudflare Worker Endpoints

#### GET /poai/status
```bash
curl https://your-worker.workers.dev/poai/status
```

Response:
```json
{
  "chainHead": {
    "height": 1268,
    "hash": "0x742d35c7...",
    "timestamp": 1703875200000,
    "poaiDigest": "violet_af_quantum_digest_1268_∞"
  },
  "recentDigests": [...],
  "pendingSubmissions": 7,
  "network": {
    "name": "VIOLET-AF PoAI Chain",
    "version": "1.0.0",
    "creator": "ALC-ROOT-1010-1111-XCOV∞"
  }
}
```

#### POST /poai/submit
```bash
curl -X POST https://your-worker.workers.dev/poai/submit \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "ALC-ROOT-1010-1111-XCOV∞",
    "deviceId": "SM-G998B_001",
    "digest": "a1b2c3...",
    "signature": "def456...",
    "attestationToken": "eyJ0eXAi...",
    "timestamp": 1703875200
  }'
```

### PoAI Simulator API

#### GET /api/devices
```bash
curl http://localhost:8000/api/devices
```

#### PUT /api/devices/{device_id}
```bash
curl -X PUT http://localhost:8000/api/devices/SIM_GALAXY_S24_001 \
  -H "Content-Type: application/json" \
  -d '{"battery_level": 85, "is_charging": true}'
```

## Energy Policy Details

### Requirements Matrix

| Condition | Requirement | Rationale |
|-----------|-------------|-----------|
| Battery Level | >70% OR Charging | Prevent device drain |
| Screen State | Off | Reduce power consumption |
| CPU Temperature | <45°C | Thermal protection |
| Network | WiFi preferred | Data efficiency |
| Time Window | Configurable | Peak/off-peak optimization |

### Mobile Implementation

The Android service monitors:
- `BatteryManager` for charge state and level
- `PowerManager` for screen state
- Thermal sensors for CPU temperature
- `ConnectivityManager` for network state

### Backend Validation

The Cloudflare Worker validates:
- Energy policy compliance in submission metadata
- Device attestation with Play Integrity
- Rate limiting based on energy compliance
- Historical compliance tracking

## Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/quantum-enhancement`
3. **Make your changes** with proper UID attribution
4. **Ensure all tests pass**: `npm test && python -m pytest`
5. **Sign your commits**: `git commit -S -m "Add quantum feature"`
6. **Submit a pull request** with detailed description

### Development Standards

- **UID Attribution**: Include `ALC-ROOT-1010-1111-XCOV∞` in all new components
- **Energy Awareness**: Respect energy policy in all computations
- **Quantum Integration**: Leverage quantum engine where applicable
- **Security First**: Hardware-backed keys, signed commits, attestation
- **Mobile-First**: Optimize for mobile device constraints

## Deployment

### Production Checklist

- [ ] Cloudflare Worker deployed with production secrets
- [ ] D1 database configured with proper schema
- [ ] R2 storage bucket created with CORS
- [ ] Frontend deployed to Cloudflare Pages
- [ ] Smart contracts deployed and verified
- [ ] GitHub security rules configured
- [ ] Energy policy enforcement active
- [ ] Monitoring and alerting configured

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `CREATOR_UID` | Creator identification | `ALC-ROOT-1010-1111-XCOV∞` |
| `CREATOR_EMAIL` | Creator contact | `allcatch37@gmail.com` |
| `POAI_API_KEY` | Secure API authentication | `violet-af-abc123...` |
| `CLOUDFLARE_API_TOKEN` | Deployment authentication | `cf_token_...` |

## Support & Contact

- **Creator**: Andrew Lee Cruz
- **UID**: ALC-ROOT-1010-1111-XCOV∞
- **ORCID**: https://orcid.org/0009-0000-3695-1084
- **Email**: allcatch37@gmail.com
- **License**: Universal Creator License (UCL-∞)

## License

This project is licensed under the Universal Creator License (UCL-∞). See [LICENSE-UCL-INF.txt](LICENSE-UCL-INF.txt) for details.

All intellectual property rights are reserved by Andrew Lee Cruz. Unauthorized use, reproduction, or derivative creation without express written permission is prohibited and subject to enforcement under OmniChain sovereignty protocols.

---

**VIOLET-AF: Autonomous Quantum Logic Initialization & PoAI Stack v1.0.0**  
*Quantum-Enhanced • Energy-Aware • Production-Ready*  
*Creator: Andrew Lee Cruz (UID: ALC-ROOT-1010-1111-XCOV∞)*
