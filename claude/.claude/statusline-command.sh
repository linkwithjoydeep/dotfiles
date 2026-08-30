#!/bin/bash
# Claude Code status line: model, effort, context usage (tokens + percentage)

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
effort=$(echo "$input" | jq -r '.effort.level // empty')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

total_tokens=$((input_tokens + output_tokens))

# format large token counts as e.g. 12.3k
format_tokens() {
  local n=$1
  if [ "$n" -ge 1000 ]; then
    awk -v n="$n" 'BEGIN { printf "%.1fk", n/1000 }'
  else
    echo "$n"
  fi
}

total_fmt=$(format_tokens "$total_tokens")

if [ -n "$window_size" ]; then
  window_fmt=$(format_tokens "$window_size")
  tokens_str="${total_fmt}/${window_fmt}"
else
  tokens_str="$total_fmt"
fi

if [ -n "$used_pct" ]; then
  pct_str=$(printf "%.0f%%" "$used_pct")
  ctx_str="Context: ${tokens_str} (${pct_str})"
  overload=$(awk -v p="$used_pct" 'BEGIN { print (p > 40) ? 1 : 0 }')
else
  ctx_str="Context: n/a"
  overload=0
fi

if [ -n "$effort" ]; then
  effort_str="Effort: ${effort}"
else
  effort_str="Effort: n/a"
fi

dim="\033[2m"
red_bold="\033[1;31m"
reset="\033[0m"

if [ "$overload" = "1" ]; then
  printf "${dim}%s | %s | ${red_bold}%s — context overload${reset}" "$model" "$effort_str" "$ctx_str"
else
  printf "${dim}%s | %s | %s${reset}" "$model" "$effort_str" "$ctx_str"
fi
