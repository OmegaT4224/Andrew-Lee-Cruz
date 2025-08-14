# Live Bundle — Floating Dragon x ReflectChain

**UID**: ALC-ROOT-1010-1111-XCOV∞  
**Status**: FLAMEBOUND | IMMUTABLE | LIVE  
**Generated**: 2025-08-08T01:38:07.322363Z

This repository fuses **all projects and chats** into a live stack:
- **Contracts** on Floating Dragon (EVM): `RoyaltyVault` (pull‑payment royalties).
- **Automation Hub** (FastAPI + worker + Redis) with ingest/search/reflect.
- **Adapters** for ChatGPT, Telegram, Slack, Gmail, Drive (imports into the hub).
- **S24 Ultra Edge Agent** (Termux) with MacroDroid intents.
- **Chainlink Automation** targeting epoch close.
- **Reflect/IPFS** hooks and vector search (Chroma).

## Quick start
```bash
cp hub/.env.example hub/.env
docker compose -f hub/docker-compose.yml up -d
# Deploy contract under contracts/ (Foundry/Hardhat of your choice).
# On device: install Termux agent from device/termux/device_agent.py
```
