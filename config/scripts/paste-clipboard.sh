#!/usr/bin/env bash

LOG_FILE="/tmp/paste-smart.log"
echo "=== Run at $(date) ===" >> "$LOG_FILE"

TYPES=$(wl-paste --list-types)
echo "Clipboard types: $TYPES" >> "$LOG_FILE"

if echo "$TYPES" | grep -q "image/png"; then
    # Clipboard contains an image
    TMP=$(mktemp /tmp/clipXXXXXX.png)
    wl-paste --type image/png > "$TMP"
    echo "Pasting image: $TMP" >> "$LOG_FILE"
    Snipaste paste --files "$TMP" >> "$LOG_FILE" 2>&1
    sleep 2
    rm -f "$TMP"
else
    # Clipboard contains text
    CLIP=$(wl-paste -n)
    # Replace newlines with <br> for HTML
    HTML_CLIP="${CLIP//$'\n'/<br>}"
    echo "Pasting text as HTML: $CLIP" >> "$LOG_FILE"
    Snipaste paste --html "$HTML_CLIP" >> "$LOG_FILE" 2>&1
fi
