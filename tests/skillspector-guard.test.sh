#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

skill_dir="$repo_root/home/dot_agent/skills/skillspector-guard"
codex_link="$repo_root/home/dot_codex/skills/symlink_skillspector-guard"
claude_link="$repo_root/home/dot_claude/skills/symlink_skillspector-guard"
expected_target="../../.agent/skills/skillspector-guard"

test -f "$skill_dir/SKILL.md"
test -f "$skill_dir/agents/openai.yaml"

test "$(cat "$codex_link")" = "$expected_target"
test "$(cat "$claude_link")" = "$expected_target"

test ! -e "$repo_root/home/dot_codex/skills/skillspector-guard"
test ! -e "$repo_root/home/dot_claude/skills/skillspector-guard"
