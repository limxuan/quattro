#!/usr/bin/env bash
# Declarative application definitions

webapps=(
  "Calendar|https://calendar.google.com/|https://www.google.com/s2/favicons?domain=calendar.google.com&sz=128"
  "ChatGPT|https://chatgpt.com/|https://www.google.com/s2/favicons?domain=chatgpt.com&sz=128"
  "Claude|https://claude.ai/new|https://www.google.com/s2/favicons?domain=claude.ai&sz=128"
  "Gemini|https://gemini.google.com/app|https://www.google.com/s2/favicons?domain=gemini.google.com&sz=128"
  "Discord|https://discord.com/app|https://www.google.com/s2/favicons?domain=discord.com&sz=128"
  "GitHub|https://github.com/|https://www.google.com/s2/favicons?domain=github.com&sz=128"
  "Teams|https://teams.microsoft.com/v2/|https://www.google.com/s2/favicons?domain=teams.microsoft.com&sz=128"
  "WhatsApp|https://web.whatsapp.com/|https://www.google.com/s2/favicons?domain=web.whatsapp.com&sz=128"
  "OneNote|https://onenote.cloud.microsoft/|https://www.google.com/s2/favicons?domain=onenote.cloud.microsoft&sz=128"
)

tui_apps=(
  "Disk Usage|dust -r; read -n 1 -s|Disk Usage.png|TUI.float"
  "Docker|lazydocker|Docker.png|TUI.tile"
)

omarchy_shortcuts=(
  "bluetooth|Bluetooth|bluetooth|omarchy-shell shell toggle omarchy.bluetooth|Bluetooth Settings|Settings;Hardware;|bluetooth;bt;wireless;"
  "screenshot-editor|Screenshot Editor (Satty)|satty|$HOME/.config/scripts/edit-clipboard-with-satty.sh|Edit and annotate screenshot with Satty|Utility;|screenshot;satty;annotate;markup;editor;image;snip;"
  "sound|Sound|audio-volume-high|omarchy-launch-or-focus-tui wiremix|Audio Mixer (Wiremix)|Settings;Audio;|sound;audio;volume;mixer;wiremix;"
  "wifi|Wi-Fi|network-wireless|omarchy-shell shell toggle omarchy.network|Wi-Fi and Network Settings|Settings;Network;|wifi;wi-fi;network;internet;wireless;ssid;wlan;"
)
