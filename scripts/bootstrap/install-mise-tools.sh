#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  curl https://mise.run | sh
fi

mise install
