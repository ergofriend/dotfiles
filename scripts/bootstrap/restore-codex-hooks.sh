#!/usr/bin/env bash
set -euo pipefail

# Keep this as a separate bootstrap step after `apm install -g`.
#
# Why this exists:
# - APM manages Superpowers for Codex from `home/dot_apm/apm.yml`.
# - Superpowers v5.1.0 includes hook definitions that are valid for
#   Claude/Cursor-style plugin layouts, but not for this Codex setup.
# - In practice, APM can write `~/.codex/hooks.json` with commands like:
#     "${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start
#   or:
#     ./hooks/run-hook.cmd session-start
# - Codex does not set `CLAUDE_PLUGIN_ROOT` here, and `./hooks` does not exist
#   under the Codex working directory, so SessionStart fails with exit 127.
#
# `home/dot_codex/hooks.json` is the source of truth for the Codex-safe hook.
# This script copies that file back into place after APM has finished, so APM
# can continue to manage skills while this dotfiles repo owns the Codex hook
# compatibility patch.
#
# Removal condition:
# Once the pinned Superpowers/APM combination writes a Codex-safe SessionStart
# hook by itself, this script and the `restore-codex-hooks.sh` bootstrap call can
# be removed.
hooks_source="${1:?usage: restore-codex-hooks.sh HOOKS_SOURCE [HOOKS_TARGET]}"
hooks_target="${2:-$HOME/.codex/hooks.json}"

mkdir -p "$(dirname "$hooks_target")"
install -m 0644 "$hooks_source" "$hooks_target"
