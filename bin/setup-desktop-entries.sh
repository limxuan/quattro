#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$DESKTOP_DIR/icons"
mkdir -p "$ICON_DIR"

declare -a webapps=() tui_apps=() omarchy_shortcuts=()
source "$SCRIPT_DIR/apps.sh"

# 1. Web Apps
if (( ${#webapps[@]} > 0 )); then
  echo "[+] Installing web app desktop entries..."

  for entry in "${webapps[@]}"; do
    IFS='|' read -r name url icon_url <<< "$entry"
    echo "    $name"

    local_icon="$ICON_DIR/$name.png"
    curl -fsSL -o "$local_icon" "$icon_url" 2>/dev/null || true

    if command -v omarchy-webapp-install &>/dev/null; then
      if [[ -s $local_icon ]]; then
        omarchy-webapp-install "$name" "$url" "$name.png" 2>/dev/null || true
      else
        omarchy-webapp-install "$name" "$url" "" 2>/dev/null || true
      fi
    else
      desktop_file="$DESKTOP_DIR/$name.desktop"
      cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Name=$name
Exec=omarchy-launch-webapp $url
Terminal=false
Type=Application
StartupNotify=true
EOF
      [[ -s $local_icon ]] && echo "Icon=$local_icon" >> "$desktop_file"
      chmod +x "$desktop_file"
    fi
  done
fi

# 2. Omarchy Shortcuts
if (( ${#omarchy_shortcuts[@]} > 0 )); then
  echo "[+] Installing Omarchy shortcut desktop entries..."

  for entry in "${omarchy_shortcuts[@]}"; do
    IFS='|' read -r id name icon exec_cmd comment categories keywords <<< "$entry"
    echo "    $name"

    desktop_file="$DESKTOP_DIR/${id:-$name}.desktop"
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Exec=$exec_cmd
Terminal=false
StartupNotify=false
EOF
    [[ -n "$icon" ]] && echo "Icon=$icon" >> "$desktop_file"
    [[ -n "$comment" ]] && echo "Comment=$comment" >> "$desktop_file"
    [[ -n "$categories" ]] && echo "Categories=$categories" >> "$desktop_file"
    [[ -n "$keywords" ]] && echo "Keywords=$keywords" >> "$desktop_file"
    chmod +x "$desktop_file"
  done
fi

# 3. Bitwarden Autostart & Desktop entry
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/bitwarden.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Bitwarden
Comment=Bitwarden Password Manager
Exec=/usr/bin/bitwarden --autostart
Icon=bitwarden
Terminal=false
Categories=Utility;
X-GNOME-Autostart-enabled=true
EOF

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo "[+] Desktop entries setup complete!"
