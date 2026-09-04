#!/usr/bin/env bash
set -e

echo "[+] Setting up Chromium extensions policy and browser defaults..."

# 1. Configure Chromium Enterprise Policy for Extensions
echo "[+] Configuring Chromium managed extensions policy..."

cat << 'EOF' > /tmp/chromium_extensions.json
{
  "ExtensionInstallForcelist": [
    "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx",
    "hfjbmagddngcpeloejdejnfgbamkjaeg;https://clients2.google.com/service/update2/crx",
    "eimadpbcbfnmbkopoojfekhnkhdbieeh;https://clients2.google.com/service/update2/crx",
    "gcknhkkoolaabfmlnjonogaaifnjlfnp;https://clients2.google.com/service/update2/crx",
    "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx",
    "fipfgiejfpcdacpjepkohdlnjonchnal;https://clients2.google.com/service/update2/crx"
  ]
}
EOF

sudo install -Dm644 /tmp/chromium_extensions.json /etc/chromium/policies/managed/chromium_extensions.json
sudo install -Dm644 /tmp/chromium_extensions.json /etc/opt/chrome/policies/managed/chromium_extensions.json
rm -f /tmp/chromium_extensions.json

# Clean up old policy files if present
sudo rm -f /etc/chromium/policies/managed/helium_extensions.json 2>/dev/null || true

# 2. Set Chromium as the default browser and web handler
if command -v xdg-settings &>/dev/null; then
    xdg-settings set default-web-browser chromium.desktop 2>/dev/null || true
    xdg-mime default chromium.desktop x-scheme-handler/http 2>/dev/null || true
    xdg-mime default chromium.desktop x-scheme-handler/https 2>/dev/null || true
    xdg-mime default chromium.desktop text/html 2>/dev/null || true
fi

# 3. Clean up legacy Helium artifacts if present
rm -rf "$HOME/.config/net.imput.helium" 2>/dev/null || true
rm -f "$HOME/.config/helium-browser-flags.conf" 2>/dev/null || true
rm -f "$HOME/.local/bin/helium-browser" 2>/dev/null || true
rm -f "$HOME/.local/share/applications/helium.desktop" 2>/dev/null || true

if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

echo "[+] Chromium setup completed successfully!"
