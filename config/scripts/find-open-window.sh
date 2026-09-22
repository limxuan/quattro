#!/usr/bin/env bash

# Check if running inside terminal
if [ ! -t 0 ]; then
    # Not in terminal, spawn one
    kitty --class=float-window -e "$0" "$@"
    exit 0
fi

# Get list of windows with address and workspace ID prepended
# Format per line: <address>|<workspace_id>\tWS:<workspace_id> | <class> | <title>
windows=$(hyprctl clients -j 2>/dev/null | jq -r '
    .[] | select(.mapped == true and .workspace.id > 0)
    | "\(.address)|\(.workspace.id)\tWS:\(.workspace.id) | \(.class) | \(.title)"' | sort -t'|' -k2,2n)

# Exit if no windows found
[[ -z "$windows" ]] && exit 0

# Let user select using fzf (--with-nth=2 hides the address/workspace prefix from view)
selected=$(echo "$windows" | fzf \
    --delimiter='\t' \
    --with-nth=2 \
    --prompt="Switch to window: " \
    --height=40% \
    --reverse \
    --border \
    --preview-window=hidden)

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Extract address and workspace ID directly from the hidden first column
meta=$(echo "$selected" | cut -f1)
address=$(echo "$meta" | cut -d'|' -f1)
workspace=$(echo "$meta" | cut -d'|' -f2)

# Focus workspace first if needed, then focus the window
if [ -n "$address" ]; then
    if [ -n "$workspace" ]; then
        hyprctl dispatch "hl.dsp.focus({ workspace = '$workspace' })" >/dev/null 2>&1 || true
    fi
    hyprctl dispatch "hl.dsp.focus({ window = 'address:$address' })" >/dev/null 2>&1 || true
fi
