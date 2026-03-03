#!/bin/bash

# FIFO for cava
PIPE="$HOME/.cache/cava.fifo"

# Create FIFO if missing
if [[ ! -p "$PIPE" ]]; then
  mkfifo "$PIPE"
fi

# Start cava in fifo mode if not running
pgrep -f "cava -p" >/dev/null || cava -p ~/.config/cava/waybar.conf &

# Read bars and output JSON to Waybar
while IFS= read -r raw; do
  cleaned="${raw//;/ }"
  bars=""

  for n in $cleaned; do
    # Make sure n is a number before doing math
    if [[ "$n" =~ ^[0-9]+$ ]]; then
      level=$(( n / 100 ))  # More granular levels for smoother animation
      (( level > 10 )) && level=10
      
      # Enhanced bar characters for smoother appearance
      blocks=("⠀" "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" "🮂" "🮃")
      bar="${blocks[$level]}"
      
      # Color gradient from blue -> cyan -> green -> yellow -> red
      if (( level <= 2 )); then
        color="#5e81ac"  # Blue
      elif (( level <= 4 )); then
        color="#88c0d0"  # Cyan  
      elif (( level <= 6 )); then
        color="#a3be8c"  # Green
      elif (( level <= 8 )); then
        color="#ebcb8b"  # Yellow
      else
        color="#bf616a"  # Red
      fi
      
      bars+="<span color='$color'>$bar</span>"
    fi
  done

  echo "{\"text\": \"$bars\"}"
done < "$PIPE"

