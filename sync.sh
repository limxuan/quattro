#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Syncing dotfiles from $DOTFILES_DIR..."

backup_and_link() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ]; then
        rm -f "$dest"
    elif [ -e "$dest" ]; then
        local bak="${dest}.bak.$(date +%s)"
        echo "  [i] Backing up existing $dest -> $bak"
        mv "$dest" "$bak"
    fi

    ln -s "$src" "$dest"
    echo "  [✓] Linked $dest -> $src"
}

# 1. Link .bashrc
backup_and_link "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# 2. Link config directories and files
for item in "$DOTFILES_DIR/config"/*; do
    name="$(basename "$item")"
    backup_and_link "$item" "$HOME/.config/$name"
done

# 3. Make scripts executable
chmod +x "$DOTFILES_DIR/config/scripts/"*.sh 2>/dev/null || true
chmod +x "$DOTFILES_DIR/config/hypr/toggle-layout.sh" 2>/dev/null || true
chmod +x "$DOTFILES_DIR/bin/"*.sh 2>/dev/null || true

echo "[+] Sync completed successfully!"
