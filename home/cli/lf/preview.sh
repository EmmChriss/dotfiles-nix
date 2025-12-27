#!/bin/bash

# don't preview over sshfs
if [ -n "$id" ] && echo "$PWD" | grep -q 'sshfs'; then
	lf -remote "send $id set nopreview"
	lf -remote "send $id resize"
fi

FILE="$1"
# HEIGHT="$2"

MIME="$(file -biL "$FILE")"
# MT="$(echo "$MIME" | cut -d ';' -f 1)"
ME="$(echo "$MIME" | cut -d '=' -f 2)"
# EXT="${FILE#/*/*.}"

# Style on
printf "\e[7m"
if test "$(file -bi "$FILE" | cut -d ';' -f 1)" = 'inode/symlink'; then
	printf "> %s\n" "$(realpath "$FILE")"
fi

# Write header: <path> <mimetype>... and some other info? with color
printf "%s\n\e[0m" "$MIME"

# Handle text-files specifically
if echo "$ME" | grep -q -e 'ascii' -e 'utf'; then
  bat --paging=never --color=always --style=changes "$FILE" && exit
  cat "$FILE" && exit
fi

# Handle archive files specifically
ouch list --tree --yes --accessible --gitignore "$FILE" 2>/dev/null && exit

# Fallback
echo "File Type" && file --dereference --brief -- "$FILE" | sed 's/, /\n/g'

