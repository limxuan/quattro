#!/usr/bin/env bash

# Find existing ssh-agent socket or start a new one
AGENT_SOCK=$(find /tmp -name "agent.*" -user "$USER" 2>/dev/null | head -1)

if [ -n "$AGENT_SOCK" ]; then
    export SSH_AUTH_SOCK="$AGENT_SOCK"
elif pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
else
    eval "$(ssh-agent -s)" > /dev/null
fi

# Add all SSH keys from ~/.ssh/
for key in "$HOME"/.ssh/id_* "$HOME"/.ssh/*_key; do
    # Skip public keys and known_hosts
    [[ "$key" == *.pub ]] && continue
    [[ "$key" == *known_hosts* ]] && continue
    
    if [ -f "$key" ]; then
        ssh-add "$key" 2>/dev/null || true
    fi
done
