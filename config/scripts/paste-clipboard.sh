#!/usr/bin/env bash

TYPES=$(wl-paste --list-types 2>/dev/null)

if [ -z "$TYPES" ]; then
    notify-send "📋 Clipboard" "Clipboard is empty" -i dialogue-warning -t 2000
    exit 0
fi

if echo "$TYPES" | grep -q "image/png"; then
    # Clipboard contains an image
    TMP=$(mktemp /tmp/clipXXXXXX.png)
    wl-paste --type image/png > "$TMP"

    # Spawn floating kitty terminal to show image
    kitty --class=float-paste --title="Clipboard Image" bash -c \
        "trap 'rm -f \"$TMP\"' EXIT; \
         kitten icat --align=center \"$TMP\"; \
         read -n 1 -s -r -p 'Press any key to close...'" &
else
    # Clipboard contains text
    TMP=$(mktemp /tmp/clipXXXXXX.txt)
    wl-paste -n > "$TMP"

    # Spawn floating kitty terminal to show text with bat
    kitty --class=float-paste --title="Clipboard Note" bash -c \
        "trap 'rm -f \"$TMP\"' EXIT; \
         bat --style=plain --paging=always \"$TMP\"" &
fi
