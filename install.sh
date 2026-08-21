#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "============================================="
echo "       Omarchy 4.0 Dotfiles Installer        "
echo "============================================="

# 1. Install Pacman packages
if command -v pacman &>/dev/null; then
    echo "[1/6] Installing pacman packages..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/packages/pacman.txt"
fi

# 2. Install Yay & AUR packages
if ! command -v yay &>/dev/null; then
    echo "[2/6] Installing yay AUR helper..."
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

if [ -f "$DOTFILES_DIR/packages/aur.txt" ]; then
    echo "[+] Installing AUR packages..."
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/packages/aur.txt"
fi

# 3. Setup Keyd and libinput quirks
echo "[3/6] Setting up Keyd and hardware quirks..."
sudo mkdir -p /etc/keyd /etc/libinput
sudo cp "$DOTFILES_DIR/etc/keyd/default.conf" /etc/keyd/default.conf
sudo cp "$DOTFILES_DIR/etc/libinput/local-overrides.quirks" /etc/libinput/local-overrides.quirks
sudo systemctl enable --now keyd.service
sudo systemctl restart keyd.service || true

# 4. Install Sesh terminal assistant
if ! command -v sesh &>/dev/null; then
    echo "[+] Installing Sesh binary..."
    mkdir -p "$HOME/.local/bin"
    LATEST_SESH_URL=$(curl -s https://api.github.com/repos/joshmedeski/sesh/releases/latest | grep "browser_download_url" | grep "Linux_x86_64.tar.gz" | head -n 1 | cut -d '"' -f 4)
    curl -L -s -o /tmp/sesh.tar.gz "${LATEST_SESH_URL}"
    tar -xzf /tmp/sesh.tar.gz -C "$HOME/.local/bin" sesh
    chmod +x "$HOME/.local/bin/sesh"
    rm -f /tmp/sesh.tar.gz
fi

# 5. Install ble.sh (bash syntax highlighting and autosuggestions)
if [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
    echo "[4/6] Installing ble.sh for Bash..."
    rm -rf /tmp/blesh
    git clone --depth 1 --recurse-submodules https://github.com/akinomyoga/ble.sh.git /tmp/blesh
    make -C /tmp/blesh install PREFIX="$HOME/.local"
    rm -rf /tmp/blesh
fi

# 5. Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "[+] Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# 6. Link configurations
echo "[5/6] Linking dotfiles configurations..."
bash "$DOTFILES_DIR/sync.sh"

# 7. Setup desktop entries and webapps
echo "[6/6] Setting up desktop entries and web apps..."
bash "$DOTFILES_DIR/bin/setup-desktop-entries.sh"

# Setup Helium browser if present
if command -v helium-browser-bin &>/dev/null || [ -f /opt/helium-browser-bin/chrome ]; then
    bash "$DOTFILES_DIR/bin/setup-helium.sh"
fi

# Validate compositor
if command -v hyprctl &>/dev/null; then
    hyprctl reload 2>/dev/null || true
fi

echo "============================================="
echo "   Installation completed successfully!      "
echo "============================================="
