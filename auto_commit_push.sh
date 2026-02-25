#!/bin/zsh
cd "$(dirname "$0")"

while true; do
  fswatch -1 .
  git add .
  git commit -m "auto: save $(date '+%Y-%m-%d %H:%M:%S')" || continue
  git push
done