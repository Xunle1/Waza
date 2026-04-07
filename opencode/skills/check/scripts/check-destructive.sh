#!/usr/bin/env bash
# Advisory preflight for review sessions.
# Exit 0 = allow, exit 2 = block and explain.
set -euo pipefail

if [ "$#" -gt 0 ]; then
  INPUT="$1"
elif [ -n "${OPENCODE_TOOL_INPUT:-}" ]; then
  INPUT="$OPENCODE_TOOL_INPUT"
elif [ -n "${TOOL_INPUT:-}" ]; then
  INPUT="$TOOL_INPUT"
else
  INPUT="$(cat /dev/stdin 2>/dev/null || true)"
fi

patterns=(
  'git push --force'
  'git push -f '
  'git reset --hard'
  'git clean -fd'
  'git clean -f'
  'rm -rf /'
  'DROP TABLE'
  'DROP DATABASE'
  'TRUNCATE '
  '--no-verify'
)

for pattern in "${patterns[@]}"; do
  if [[ "$INPUT" == *"$pattern"* ]]; then
    printf 'BLOCK: risky command detected during review: %s\n' "$pattern" >&2
    printf 'OpenCode skill-level blocking is advisory only. Confirm with the user before proceeding.\n' >&2
    exit 2
  fi
done

exit 0
