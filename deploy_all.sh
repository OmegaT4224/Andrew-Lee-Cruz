#!/usr/bin/env bash
set -euo pipefail

echo ">> Compiling & deploying contracts (requires Foundry/forge in PATH)..."
forge --version >/dev/null 2>&1 || { echo "Install Foundry: https://book.getfoundry.sh/"; exit 1; }

forge build

# Example (adjust networks and private keys per your env)
# forge create --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY contracts/CreatorAttribution.sol:CreatorAttribution
# forge create --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY contracts/OmniChainGenesis.sol:OmniChainGenesis
# forge create --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY contracts/RoyaltyLicensingEnforcer.sol:RoyaltyLicensingEnforcer --constructor-args 0xYourBeneficiary 500
# forge create --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY contracts/AIValidatorOverlay.sol:AIValidatorOverlay
# forge create --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY contracts/FlameCertNFT.sol:FlameCertNFT

echo ">> Done."
