#!/usr/bin/env bash
# Navigate current tmux pane back to the base directory of the session

SESSION_PATH="$1"
SESSION_NAME="$2"
PANE_ID="$3"

target="$SESSION_PATH"

# If session_path is not a valid directory or is HOME, try resolving via zoxide
if [ -z "$target" ] || [ ! -d "$target" ] || [ "$target" = "$HOME" ]; then
    zdir=$(zoxide query "$SESSION_NAME" 2>/dev/null)
    if [ -n "$zdir" ] && [ -d "$zdir" ]; then
        target="$zdir"
    fi
fi

if [ -n "$target" ] && [ -d "$target" ]; then
    tmux send-keys -t "$PANE_ID" C-u "cd \"$target\"" Enter
fi
