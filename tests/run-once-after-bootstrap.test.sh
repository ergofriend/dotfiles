#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fake_home="$tmpdir/home"
mkdir -p "$fake_home/.local/bin"

cat >"$fake_home/.local/bin/mise" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${1:-}" = "install" ]; then
  exit 0
fi
if [ "${1:-}" = "exec" ]; then
  shift
  if [ "${1:-}" = "github:microsoft/apm" ]; then
    shift
  fi
  exec "$@"
fi
echo "unexpected mise args: $*" >&2
exit 1
EOF
chmod +x "$fake_home/.local/bin/mise"

cat >"$fake_home/.local/bin/apm" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "$*" != "install -g" ]; then
  echo "unexpected apm args: $*" >&2
  exit 1
fi
mkdir -p "$HOME/.codex"
cat >"$HOME/.codex/hooks.json" <<'JSON'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
JSON
EOF
chmod +x "$fake_home/.local/bin/apm"

HOME="$fake_home" \
PATH="/usr/bin:/bin" \
ERGODOTFILES_SOURCE_DIR="$repo_root" \
bash "$repo_root/home/run_once_after_bootstrap.sh"

hooks_file="$fake_home/.codex/hooks.json"
test -f "$hooks_file"
node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$hooks_file"
cmp -s "$repo_root/home/dot_codex/hooks.json" "$hooks_file"
grep -Fq '\"${HOME}/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd\" session-start' "$hooks_file"
grep -Fq '${HOME}/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd session-start' "$hooks_file"
if grep -Fq 'CLAUDE_PLUGIN_ROOT' "$hooks_file"; then
  echo "hooks.json still references CLAUDE_PLUGIN_ROOT" >&2
  exit 1
fi
