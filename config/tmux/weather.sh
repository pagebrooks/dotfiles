#!/bin/bash
cache="/tmp/tmux-weather-losgatosca"
max_age=900 # 15 minutes

if [ -f "$cache" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$cache") ))
  if [ "$age" -lt "$max_age" ]; then
    cat "$cache"
    exit 0
  elif [ "$age" -gt 3600 ]; then
    rm -f "$cache"
  fi
fi

temp=$(curl -s --max-time 5 "wttr.in/Los+Gatos,CA?format=%t&u" 2>/dev/null)
if [ -n "$temp" ] && echo "$temp" | grep -q 'F'; then
  temp=$(echo "$temp" | sed 's/^+//')
  echo "$temp" > "$cache"
  cat "$cache"
fi
