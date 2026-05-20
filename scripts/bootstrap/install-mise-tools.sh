#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  curl https://mise.run | sh
fi

mise install
mise exec github:microsoft/apm -- apm install -g
# Claude integration currently does not patch settings correctly in non-interactive bootstrap.
# mise exec rtk -- rtk init -g --agent claude
mise exec rtk -- rtk init -g --codex
