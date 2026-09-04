#!/usr/bin/env bash
set -e

echo "[+] Setting up Chromium extensions policy and browser defaults..."

# 1. Configure Chromium Enterprise Policy for Extensions
echo "[+] Configuring Chromium managed extensions policy..."
mkdir -p /etc/chromium/policies/managed 2>/dev/null || true

python3 << 'EOF'
import json, os

policy = {
    "ExtensionInstallForcelist": [
        "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx",  # SponsorBlock
        "hfjbmagddngcpeloejdejnfgbamkjaeg;https://clients2.google.com/service/update2/crx",  # Vimium C
        "eimadpbcbfnmbkopoojfekhnkhdbieeh;https://clients2.google.com/service/update2/crx",  # Dark Reader
        "gcknhkkoolaabfmlnjonogaaifnjlfnp;https://clients2.google.com/service/update2/crx",  # FoxyProxy
        "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx",  # Bitwarden
        "fipfgiejfpcdacpjepkohdlnjonchnal;https://clients2.google.com/service/update2/crx"   # Manage Tabs
    ]
}

target_dirs = [
    "/etc/chromium/policies/managed",
    "/etc/opt/chrome/policies/managed"
]

for d in target_dirs:
    try:
        os.makedirs(d, exist_ok=True)
        path = os.path.join(d, "chromium_extensions.json")
        with open(path, "w") as f:
            json.dump(policy, f, indent=2)
        print(f"    Wrote extension policy to {path}")
    except Exception as e:
        print(f"    Notice: could not write to {d} ({e})")
EOF

# Clean up old policy files if present
rm -f /etc/chromium/policies/managed/helium_extensions.json 2>/dev/null || true

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
