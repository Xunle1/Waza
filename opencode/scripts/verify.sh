#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OPENCODE_DIR="$ROOT_DIR/opencode"

required_files=(
  "$ROOT_DIR/.gitignore"
  "$OPENCODE_DIR/README.md"
  "$OPENCODE_DIR/install.sh"
  "$OPENCODE_DIR/docs/capability-matrix.md"
  "$OPENCODE_DIR/scripts/statusline.sh"
  "$OPENCODE_DIR/scripts/setup-statusline.sh"
  "$OPENCODE_DIR/scripts/verify.sh"
  "$OPENCODE_DIR/templates/english-coaching.md"
)

skills=(think design check hunt learn read write health)
read_assets=(
  "$OPENCODE_DIR/skills/read/references/read-methods.md"
  "$OPENCODE_DIR/skills/read/scripts/fetch.sh"
  "$OPENCODE_DIR/skills/read/scripts/fetch_feishu.py"
  "$OPENCODE_DIR/skills/read/scripts/fetch_weixin.py"
)
check_assets=(
  "$OPENCODE_DIR/skills/check/references/persona-catalog.md"
  "$OPENCODE_DIR/skills/check/agents/reviewer-security.md"
  "$OPENCODE_DIR/skills/check/agents/reviewer-architecture.md"
  "$OPENCODE_DIR/skills/check/scripts/check-destructive.sh"
  "$OPENCODE_DIR/skills/check/scripts/verify.sh"
)
health_assets=(
  "$OPENCODE_DIR/skills/health/agents/agent1-context.md"
  "$OPENCODE_DIR/skills/health/agents/agent2-control.md"
)

for file in "${required_files[@]}"; do
  [ -f "$file" ] || {
    echo "missing file: $file"
    exit 1
  }
done

grep -q '^\.opencode/$' "$ROOT_DIR/.gitignore" || {
  echo "missing .opencode/ entry in .gitignore"
  exit 1
}

grep -q '^\.worktrees/$' "$ROOT_DIR/.gitignore" || {
  echo "missing .worktrees/ entry in .gitignore"
  exit 1
}

for skill in "${skills[@]}"; do
  skill_dir="$OPENCODE_DIR/skills/$skill"
  skill_file="$skill_dir/SKILL.md"

  [ -d "$skill_dir" ] || {
    echo "missing skill directory: $skill_dir"
    exit 1
  }

  [ -f "$skill_file" ] || {
    echo "missing skill file: $skill_file"
    exit 1
  }

  grep -q "^name: $skill$" "$skill_file" || {
    echo "missing skill name frontmatter: $skill_file"
    exit 1
  }

  grep -q '^description:' "$skill_file" || {
    echo "missing skill description frontmatter: $skill_file"
    exit 1
  }

  grep -q '^# ' "$skill_file" || {
    echo "missing skill title heading: $skill_file"
    exit 1
  }
done

for file in "${read_assets[@]}"; do
  [ -f "$file" ] || {
    echo "missing read asset: $file"
    exit 1
  }
done

for file in "${check_assets[@]}"; do
  [ -f "$file" ] || {
    echo "missing check asset: $file"
    exit 1
  }
done

for file in "${health_assets[@]}"; do
  [ -f "$file" ] || {
    echo "missing health asset: $file"
    exit 1
  }
done

bash -n "$OPENCODE_DIR/skills/read/scripts/fetch.sh"
bash -n "$OPENCODE_DIR/skills/check/scripts/check-destructive.sh"
bash -n "$OPENCODE_DIR/skills/check/scripts/verify.sh"
bash -n "$OPENCODE_DIR/scripts/statusline.sh"
bash -n "$OPENCODE_DIR/scripts/setup-statusline.sh"
python3 -m py_compile \
  "$OPENCODE_DIR/skills/read/scripts/fetch_feishu.py" \
  "$OPENCODE_DIR/skills/read/scripts/fetch_weixin.py"

if grep -Eq '(^|[^[:alnum:]_])((bash|python3) scripts/)' \
  "$OPENCODE_DIR/skills/read/SKILL.md" \
  "$OPENCODE_DIR/skills/read/references/read-methods.md"; then
  echo "read skill uses non-root script paths"
  exit 1
fi

if grep -qi 'supports .*legacy docs' \
  "$OPENCODE_DIR/skills/read/references/read-methods.md" \
  "$OPENCODE_DIR/skills/read/SKILL.md"; then
  echo "read skill still claims legacy docs support"
  exit 1
fi

if grep -q 'agent-fetch.*--json' "$OPENCODE_DIR/skills/read/scripts/fetch.sh"; then
  echo "fetch.sh still exposes JSON fallback"
  exit 1
fi

if ! grep -q 'opencode/scripts/verify.sh' "$OPENCODE_DIR/skills/check/scripts/verify.sh"; then
  echo "check verify script does not delegate to opencode/scripts/verify.sh"
  exit 1
fi

if ! grep -q 'apply_patch' "$OPENCODE_DIR/skills/check/SKILL.md"; then
  echo "check skill must expose an edit path for safe fixes"
  exit 1
fi

if ! grep -q '^## Preview Format$' "$OPENCODE_DIR/skills/read/SKILL.md" || ! grep -q 'explicitly asks for preview' "$OPENCODE_DIR/skills/read/SKILL.md"; then
  echo "read skill must scope inline output to preview mode"
  exit 1
fi

if ! grep -q '^## Claude Code$' "$ROOT_DIR/README.md" || ! grep -q '^## OpenCode$' "$ROOT_DIR/README.md"; then
  echo "root README must document both Claude Code and OpenCode entry points"
  exit 1
fi

if ! grep -q 'advisory' "$OPENCODE_DIR/docs/capability-matrix.md"; then
  echo "capability matrix must document advisory command-guard downgrade"
  exit 1
fi

if ! grep -q 'fallback' "$OPENCODE_DIR/README.md" || ! grep -q 'manual' "$OPENCODE_DIR/README.md"; then
  echo "OpenCode README must document fallback and manual integration paths"
  exit 1
fi

if ! grep -q 'fallback renderer' "$OPENCODE_DIR/docs/capability-matrix.md" || ! grep -q 'manual instruction template' "$OPENCODE_DIR/docs/capability-matrix.md"; then
  echo "capability matrix must document statusline and English coaching downgrade notes"
  exit 1
fi

if ! grep -q 'manual instruction template' "$OPENCODE_DIR/templates/english-coaching.md"; then
  echo "english coaching template must document manual OpenCode integration"
  exit 1
fi

if ! grep -q 'Fallback mode' "$OPENCODE_DIR/scripts/setup-statusline.sh"; then
  echo "statusline setup must document fallback mode"
  exit 1
fi

echo "opencode verify: ok"
