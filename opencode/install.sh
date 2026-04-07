#!/bin/bash
set -euo pipefail

WAZA_OPENCODE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.opencode/skills}"

mkdir -p "$TARGET_DIR"

for dir in "$WAZA_OPENCODE_DIR"/skills/*/; do
  name=$(basename "$dir")
  target="$TARGET_DIR/$name"
  ln -sfn "$dir" "$target"
  echo "linked: $name -> $target"
done

echo
echo "Waza OpenCode skills installed to $TARGET_DIR"
echo "Run: bash opencode/scripts/verify.sh"
