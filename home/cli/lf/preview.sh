#!/bin/bash

FILE="$1"
# WIDTH="$2"
# HEIGHT="$3"
# HPOS="$4"
# VPOS="$5"

MIME="$(file -biL "$FILE")"
# MT="$(echo "$MIME" | cut -d ';' -f 1)"
ME="$(echo "$MIME" | cut -d '=' -f 2)"
# EXT="${FILE#/*/*.}"

# Write header: <path> <mimetype>... and some other info? with color
printf "\e[7m%s\n\e[0m" "$MIME"

# Handle text-files specifically
if echo "$ME" | grep -q -e 'ascii' -e 'utf'; then
	# Try to highlight with jq
	cat "$FILE" | jq -C && exit

	# Try to highlight with bat
  bat --paging=never --color=always --style=changes "$FILE" && exit

  # Just print contents
  cat "$FILE" && exit
fi

# Handle archive files specifically
timeout 5 ouch list --tree --yes --accessible --gitignore "$FILE" 2>/dev/null && exit

# Fallback
file --dereference --brief -- "$FILE" | sed 's/, /\n/g'
timeout 5 exiftool "$FILE"
