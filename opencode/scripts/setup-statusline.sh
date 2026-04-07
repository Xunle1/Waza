#!/bin/bash
# Stage the OpenCode statusline renderer for manual integration.
set -euo pipefail

DEST_DIR="$HOME/.opencode"
DEST="$DEST_DIR/statusline.sh"
RAW="https://raw.githubusercontent.com/tw93/Waza/main/opencode/scripts/statusline.sh"

mkdir -p "$DEST_DIR"

if ! command -v jq >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "Installing jq via Homebrew..."
    brew install jq
  else
    echo "Error: jq is required but not installed. Install it first: https://jqlang.github.io/jq/" >&2
    exit 1
  fi
fi

curl -sL "$RAW" -o "$DEST"
chmod +x "$DEST"

echo "Waza OpenCode statusline renderer installed to $DEST"
echo ""
echo "Fallback mode: this repo does not yet document a verified native OpenCode statusline hook."
echo "If your OpenCode host supports a command-based statusline, point it to: bash ~/.opencode/statusline.sh"
echo "Otherwise keep this script as a local renderer until that hook is confirmed."
