#!/bin/bash
# OpenCode statusline fallback renderer.
# It preserves the Claude-style output shape when the host can pipe compatible JSON.
exec 2>/dev/null

input=$(cat)

if [ -z "$input" ]; then
  printf "Context -- | 5h: -- | 7d: --\n"
  exit 0
fi

tab=$(printf '\t')
parsed=$(printf '%s' "$input" | jq -r '
  def pct($v): if $v == null then "null" else ($v | round | tostring) end;
  [
    ((.context_window.current_usage.input_tokens // 0)
     + (.context_window.current_usage.cache_creation_input_tokens // 0)
     + (.context_window.current_usage.cache_read_input_tokens // 0) | tostring),
    (.context_window.context_window_size // 0 | tostring),
    pct(.rate_limits.five_hour.used_percentage // null),
    (.rate_limits.five_hour.resets_at // "" | tostring),
    pct(.rate_limits.seven_day.used_percentage // null),
    (.rate_limits.seven_day.resets_at // "" | tostring)
  ] | @tsv
')

[ -n "$parsed" ] || {
  printf "Context -- | 5h: -- | 7d: --\n"
  exit 0
}

IFS="$tab" read -r used_tokens window_size five_pct five_reset seven_pct seven_reset <<EOF
$parsed
EOF

RESET="\033[0m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[94m"
MAGENTA="\033[95m"

format_reset() {
  local ts="$1"
  [ -z "$ts" ] && return
  local epoch now diff mins hours days
  epoch=$(printf '%s' "$ts" | tr -dc '0-9')
  [ -z "$epoch" ] && return
  now=$(date +%s)
  diff=$((epoch - now))
  [ "$diff" -le 0 ] && return
  mins=$((diff / 60))
  hours=$((mins / 60))
  days=$((hours / 24))
  if [ "$days" -ge 1 ]; then
    printf "%dd%dh" "$days" $((hours % 24))
  elif [ "$hours" -ge 1 ]; then
    printf "%dh%dm" "$hours" $((mins % 60))
  else
    printf "%dm" "$mins"
  fi
}

usage_color() {
  local pct="$1"
  if [ "$pct" -ge 90 ] 2>/dev/null; then printf "%s" "$RED"
  elif [ "$pct" -ge 70 ] 2>/dev/null; then printf "%s" "$MAGENTA"
  else printf "%s" "$BLUE"
  fi
}

ctx_pct=0
if [ "$window_size" -gt 0 ] 2>/dev/null; then
  ctx_pct=$(awk -v u="$used_tokens" -v t="$window_size" 'BEGIN { printf "%d", (u / t) * 100 }')
fi

if [ "$ctx_pct" -ge 85 ] 2>/dev/null; then
  ctx_color="$RED"
elif [ "$ctx_pct" -ge 70 ] 2>/dev/null; then
  ctx_color="$YELLOW"
else
  ctx_color="$GREEN"
fi

context_part="${DIM}Context${RESET} ${ctx_color}${ctx_pct}%${RESET}"

if [ "$five_pct" != "null" ] && [ -n "$five_pct" ]; then
  color=$(usage_color "$five_pct")
  reset_str=$(format_reset "$five_reset")
  if [ -n "$reset_str" ]; then
    five_part="${DIM}5h:${RESET} ${color}${five_pct}%${RESET} ${DIM}(${reset_str})${RESET}"
  else
    five_part="${DIM}5h:${RESET} ${color}${five_pct}%${RESET}"
  fi
else
  five_part="${DIM}5h: --${RESET}"
fi

if [ "$seven_pct" != "null" ] && [ -n "$seven_pct" ]; then
  color=$(usage_color "$seven_pct")
  reset_str=$(format_reset "$seven_reset")
  if [ -n "$reset_str" ]; then
    seven_part="${DIM}7d:${RESET} ${color}${seven_pct}%${RESET} ${DIM}(${reset_str})${RESET}"
  else
    seven_part="${DIM}7d:${RESET} ${color}${seven_pct}%${RESET}"
  fi
else
  seven_part="${DIM}7d: --${RESET}"
fi

printf "%b | %b | %b\n" "$context_part" "$five_part" "$seven_part"
