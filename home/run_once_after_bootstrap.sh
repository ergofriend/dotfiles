#!/bin/bash
set -euo pipefail

dotfiles_source_dir="${ERGODOTFILES_SOURCE_DIR:-$HOME/Documents/dev/github.com/ergofriend/dotfiles}"
bootstrap_dir="$dotfiles_source_dir/scripts/bootstrap"

export PATH="$HOME/.local/bin:$PATH"
bash "$bootstrap_dir/install-mise-tools.sh"
bash "$bootstrap_dir/restore-codex-hooks.sh" "$dotfiles_source_dir/home/dot_codex/hooks.json"
