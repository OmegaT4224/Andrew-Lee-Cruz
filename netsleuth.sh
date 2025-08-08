#!/usr/bin/env bash
set -euo pipefail
echo ">> NetSleuth: scanning for suspicious sockets..."
netstat -an | grep ESTABLISHED || true
