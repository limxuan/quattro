#!/usr/bin/env bash

if [ -f "$HOME/Applications/Telegram/Telegram" ]; then
    "$HOME/Applications/Telegram/Telegram" &
elif command -v telegram-desktop &>/dev/null; then
    telegram-desktop &
fi

omarchy-launch-or-focus-webapp "WhatsApp" "https://web.whatsapp.com/" &
omarchy-launch-or-focus-webapp "Discord" "https://discord.com/app/" &

wait
