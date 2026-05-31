#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fake_home="$tmpdir/home"
mkdir -p "$fake_home/.local/bin"
mkdir -p "$fake_home/.codex"
cat >"$fake_home/.codex/hooks.json" <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${HOME}/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ],
        "_apm_source": "superpowers"
      }
    ]
  }
}
EOF

cat >"$fake_home/.local/bin/mise" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${1:-}" = "install" ]; then
  exit 0
fi
if [ "${1:-}" = "run" ]; then
  shift
  if [ "${1:-}" = "--global" ]; then
    export ERGODOTFILES_TEST_MISE_RUN_GLOBAL=1
    shift
  fi
  case "${1:-}" in
    bootstrap)
      if [ "${ERGODOTFILES_TEST_MISE_RUN_GLOBAL:-}" != 1 ]; then
        echo "bootstrap task must run with mise run --global" >&2
        exit 1
      fi
      exec "$HOME/.config/mise/tasks/bootstrap"
      ;;
    agent-tool)
      exec "$HOME/.config/mise/tasks/agent-tool"
      ;;
    *)
      echo "unexpected mise run task: $*" >&2
      exit 1
      ;;
  esac
fi
if [ "${1:-}" = "exec" ]; then
  shift
  if [ "${1:-}" = "npm:@openai/codex" ]; then
    export ERGODOTFILES_TEST_MISE_EXEC_CODEX=1
    shift
  fi
  if [ "${1:-}" = "claude" ]; then
    export ERGODOTFILES_TEST_MISE_EXEC_CLAUDE=1
    shift
  fi
  if [ "${1:-}" = "rtk" ]; then
    export ERGODOTFILES_TEST_MISE_EXEC_RTK=1
    shift
  fi
  exec "$@"
fi
echo "unexpected mise args: $*" >&2
exit 1
EOF
chmod +x "$fake_home/.local/bin/mise"

cat >"$fake_home/.local/bin/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${ERGODOTFILES_TEST_MISE_EXEC_CODEX:-}" != 1 ]; then
  echo "codex was not run through mise exec" >&2
  exit 1
fi
case "$*" in
  "plugin list --marketplace openai-curated")
    printf '%s\n' "superpowers@openai-curated not installed /tmp/superpowers"
    ;;
  "plugin add superpowers@openai-curated")
    mkdir -p "$HOME/.codex"
    printf '%s\n' "$*" >>"$HOME/.codex/plugin-calls"
    ;;
  *)
    echo "unexpected codex args: $*" >&2
    exit 1
    ;;
esac
EOF
chmod +x "$fake_home/.local/bin/codex"

cat >"$fake_home/.local/bin/claude" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${ERGODOTFILES_TEST_MISE_EXEC_CLAUDE:-}" != 1 ]; then
  echo "claude was not run through mise exec" >&2
  exit 1
fi
case "$*" in
  "plugin marketplace list")
    printf '%s\n' "No marketplaces configured"
    ;;
  "plugin marketplace add obra/superpowers-marketplace")
    mkdir -p "$HOME/.claude"
    printf '%s\n' "$*" >>"$HOME/.claude/plugin-calls"
    ;;
  "plugin list")
    printf '%s\n' ""
    ;;
  "plugin install superpowers@superpowers-marketplace --scope user")
    mkdir -p "$HOME/.claude"
    printf '%s\n' "$*" >>"$HOME/.claude/plugin-calls"
    ;;
  *)
    echo "unexpected claude args: $*" >&2
    exit 1
    ;;
esac
EOF
chmod +x "$fake_home/.local/bin/claude"

cat >"$fake_home/.local/bin/rtk" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${ERGODOTFILES_TEST_MISE_EXEC_RTK:-}" != 1 ]; then
  echo "rtk was not run through mise exec" >&2
  exit 1
fi
case "$*" in
  "init -g --agent claude --auto-patch") ;;
  "init -g --codex") ;;
  *)
    echo "unexpected rtk args: $*" >&2
    exit 1
    ;;
esac
mkdir -p "$HOME/.rtk"
printf '%s\n' "$*" >>"$HOME/.rtk/init-calls"
EOF
chmod +x "$fake_home/.local/bin/rtk"

(
  cd "$fake_home"
  mkdir -p "$fake_home/.config/mise/tasks"
  cp "$repo_root/home/dot_config/mise/tasks/executable_bootstrap" "$fake_home/.config/mise/tasks/bootstrap"
  cp "$repo_root/home/dot_config/mise/tasks/executable_agent-tool" "$fake_home/.config/mise/tasks/agent-tool"
  chmod +x "$fake_home/.config/mise/tasks/bootstrap" "$fake_home/.config/mise/tasks/agent-tool"
  HOME="$fake_home" \
  PATH="/usr/bin:/bin" \
  ERGODOTFILES_SOURCE_DIR="$repo_root" \
  bash "$repo_root/home/run_once_after_bootstrap.sh"
)

hooks_file="$fake_home/.codex/hooks.json"
rtk_init_calls_file="$fake_home/.rtk/init-calls"
codex_plugin_calls_file="$fake_home/.codex/plugin-calls"
claude_plugin_calls_file="$fake_home/.claude/plugin-calls"
test ! -f "$hooks_file"
test -f "$rtk_init_calls_file"
test -f "$codex_plugin_calls_file"
test -f "$claude_plugin_calls_file"
cat >"$tmpdir/expected-rtk-init-calls" <<'EOF'
init -g --agent claude --auto-patch
init -g --codex
EOF
cmp -s "$tmpdir/expected-rtk-init-calls" "$rtk_init_calls_file"
printf 'plugin add superpowers@openai-curated\n' | cmp -s - "$codex_plugin_calls_file"
cat >"$tmpdir/expected-claude-plugin-calls" <<'EOF'
plugin marketplace add obra/superpowers-marketplace
plugin install superpowers@superpowers-marketplace --scope user
EOF
cmp -s "$tmpdir/expected-claude-plugin-calls" "$claude_plugin_calls_file"
