#!/bin/bash
# Laptop only: under WSL the battery is the Windows host's, so show nothing
grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null && exit 0
cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
[ -z "$cap" ] && exit 0
if [ "$cap" -gt 50 ]; then
  color="#50fa7b"
elif [ "$cap" -gt 20 ]; then
  color="#f1fa8c"
else
  color="#ff5555"
fi
charge=""
[ "$status" = "Charging" ] && charge="+"
echo "#[fg=$color]${cap}%${charge}"
