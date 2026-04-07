#!/usr/bin/env bash
# Fetch a URL as Markdown via proxy cascade.
# Special thanks to joeseesun for the excellent qiaomu-markdown-proxy project,
# which inspired the proxy cascade design and fallback logic in this script.
# https://github.com/joeseesun/qiaomu-markdown-proxy
# Usage: fetch.sh <url> [proxy_url]
# Example: fetch.sh https://example.com http://127.0.0.1:7890
set -euo pipefail

URL="${1:?Usage: fetch.sh <url> [proxy_url]}"
PROXY="${2:-}"

_curl() {
  if [ -n "$PROXY" ]; then
    https_proxy="$PROXY" http_proxy="$PROXY" curl -sL "$@"
  else
    curl -sL "$@"
  fi
}

_has_content() {
  [ "$(printf '%s\n' "$1" | wc -l)" -gt 5 ] && printf '%s\n' "$1" | grep -qv "Don't miss what's happening"
}

# 1. r.jina.ai, wide coverage and preserves image links
OUT=$(_curl "https://r.jina.ai/$URL" 2>/dev/null || true)
if _has_content "$OUT"; then printf '%s\n' "$OUT"; exit 0; fi

# 2. defuddle.md, cleaner output with YAML frontmatter
OUT=$(_curl "https://defuddle.md/$URL" 2>/dev/null || true)
if _has_content "$OUT"; then printf '%s\n' "$OUT"; exit 0; fi

# 3. defuddle CLI, last-resort local Markdown parser
if command -v defuddle >/dev/null 2>&1; then
  OUT=$(defuddle parse "$URL" -m 2>/dev/null || true)
  if _has_content "$OUT"; then printf '%s\n' "$OUT"; exit 0; fi
fi

printf 'ERROR: All fetch methods failed for: %s\n' "$URL" >&2
exit 1
