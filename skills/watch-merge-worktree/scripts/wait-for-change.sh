#!/usr/bin/env bash
# Waits until one of the given files changes, then prints "changed: <file>" and exits 0.
# Use it on a session transcript to learn when an idle session starts work again.
#
# Usage: wait-for-change.sh [-i seconds] [-t seconds] file...
#   -i  seconds between checks (default 10)
#   -t  longest wait in seconds; then it prints "timeout" and exits 1 (default 3600, 0 = no limit)
#
# Run it in the background (Bash run_in_background); its exit is the notification.

interval=10
timeout=3600
while (( $# > 0 )); do
  case $1 in
    -i) interval=$2; shift 2 ;;
    -t) timeout=$2; shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done
if (( $# == 0 )); then
  echo "usage: wait-for-change.sh [-i seconds] [-t seconds] file..." >&2
  exit 2
fi

# GNU stat (Linux, Git Bash) first, then BSD stat (macOS).
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo gone; }

files=("$@")
base=()
for i in "${!files[@]}"; do
  base[i]=$(mtime "${files[i]}")
done

SECONDS=0
while :; do
  for i in "${!files[@]}"; do
    if [[ $(mtime "${files[i]}") != "${base[i]}" ]]; then
      echo "changed: ${files[i]}"
      exit 0
    fi
  done
  if (( timeout > 0 && SECONDS >= timeout )); then
    echo "timeout: no change in ${timeout}s"
    exit 1
  fi
  sleep "$interval"
done
