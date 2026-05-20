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

cat >"$fake_home/.local/bin/rtk" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${ERGODOTFILES_TEST_MISE_EXEC_RTK:-}" != 1 ]; then
  echo "rtk was not run through mise exec" >&2
  exit 1
fi
case "$*" in
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

HOME="$fake_home" \
PATH="/usr/bin:/bin" \
ERGODOTFILES_SOURCE_DIR="$repo_root" \
bash "$repo_root/home/run_once_after_bootstrap.sh"

hooks_file="$fake_home/.codex/hooks.json"
rtk_init_calls_file="$fake_home/.rtk/init-calls"
test -f "$hooks_file"
test -f "$rtk_init_calls_file"
printf 'init -g --codex\n' | cmp -s - "$rtk_init_calls_file"
node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$hooks_file"
cmp -s "$repo_root/home/dot_codex/hooks.json" "$hooks_file"
grep -Fq '\"${HOME}/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd\" session-start' "$hooks_file"
grep -Fq '${HOME}/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd session-start' "$hooks_file"
if grep -Fq 'CLAUDE_PLUGIN_ROOT' "$hooks_file"; then
  echo "hooks.json still references CLAUDE_PLUGIN_ROOT" >&2
  exit 1
fi
