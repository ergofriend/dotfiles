#!/bin/bash
set -euo pipefail

# Install mise if not already present.
if ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  curl https://mise.run | sh
fi

# Make sure mise is callable in this script.
export PATH="$HOME/.local/bin:$PATH"

# Install all tools declared in ~/.config/mise/config.toml.
mise install
