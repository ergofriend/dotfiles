#!/usr/bin/env bash
set -euo pipefail

if command -v apm >/dev/null 2>&1; then
  apm install -g
else
  mise exec github:microsoft/apm -- apm install -g
fi
