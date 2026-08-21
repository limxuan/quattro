#!/usr/bin/env bash
set -e

echo "[+] Setting up Helium Browser extensions..."
HELIUM_CONFIG="$HOME/.config/net.imput.helium"
UNPACKED_DIR="${HELIUM_CONFIG}/unpacked-extensions"

declare -A EXTENSIONS=(
    ["mnjggcdmjocbbbhaepdhchncahnbgone"]="SponsorBlock"
    ["hfjbmagddngcpeloejdejnfgbamkjaeg"]="Vimium C"
    ["eimadpbcbfnmbkopoojfekhnkhdbieeh"]="Dark Reader"
    ["gcknhkkoolaabfmlnjonogaaifnjlfnp"]="FoxyProxy"
    ["nngceckbapebfimnlniiiahkandclblb"]="Bitwarden"
    ["fipfgiejfpcdacpjepkohdlnjonchnal"]="Keyboard Shortcuts to Manage Tabs"
)

rm -rf "${HELIUM_CONFIG}/External Extensions"

for ext_id in "${!EXTENSIONS[@]}"; do
    ext_name="${EXTENSIONS[${ext_id}]}"
    ext_dir="${UNPACKED_DIR}/${ext_id}"
    echo "  Installing ${ext_name}..."
    crx_file="/tmp/${ext_id}.crx"
    curl -L -s -o "${crx_file}" \
        "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=123.0&x=id%3D${ext_id}%26installsource%3Dondemand%26uc"

    temp_dir="/tmp/${ext_id}_temp"
    rm -rf "${temp_dir}"
    mkdir -p "${temp_dir}"
    unzip -q -o "${crx_file}" -d "${temp_dir}" 2>/dev/null || true

    version=$(python3 -c "import json; print(json.load(open('${temp_dir}/manifest.json')).get('version', '1.0'))" 2>/dev/null || echo "1.0")
    final_dir="${ext_dir}/${version}_0"

    rm -rf "${final_dir}"
    mkdir -p "${final_dir}"
    cp -r "${temp_dir}"/* "${final_dir}/"
    rm -rf "${temp_dir}" "${crx_file}"
    echo "    ${ext_name} v${version} installed"
done

# Configure Helium preferences
echo "[+] Configuring Helium preferences..."
mkdir -p "${HELIUM_CONFIG}/Default"
python3 << 'EOF'
import json, os

path = os.path.expanduser('~/.config/net.imput.helium/Default/Preferences')
os.makedirs(os.path.dirname(path), exist_ok=True)
data = {}
if os.path.exists(path):
    try:
        with open(path, 'r') as f:
            data = json.load(f)
    except Exception:
        pass

if 'helium' not in data:
    data['helium'] = {}
if 'browser' not in data['helium']:
    data['helium']['browser'] = {}
data['helium']['browser']['layout'] = 2

try:
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
except Exception as e:
    print(f"Failed to save Helium preferences: {e}")
EOF

# Create wrapper script
echo "[+] Creating Helium wrapper at ~/.local/bin/helium-browser..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/helium-browser" << 'WRAPPEREOF'
#!/usr/bin/env bash
# Helium Browser wrapper - loads unpacked extensions

EXT_PATHS=()
for ext_id in mnjggcdmjocbbbhaepdhchncahnbgone hfjbmagddngcpeloejdejnfgbamkjaeg eimadpbcbfnmbkopoojfekhnkhdbieeh gcknhkkoolaabfmlnjonogaaifnjlfnp nngceckbapebfimnlniiiahkandclblb fipfgiejfpcdacpjepkohdlnjonchnal; do
    ext_path=$(find "$HOME/.config/net.imput.helium/unpacked-extensions/${ext_id}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n 1)
    if [ -n "${ext_path}" ]; then
        EXT_PATHS+=("${ext_path}")
    fi
done

if [ ${#EXT_PATHS[@]} -gt 0 ]; then
    EXT_LIST=$(IFS=,; echo "${EXT_PATHS[*]}")
    exec /opt/helium-browser-bin/chrome --force-dark-mode --enable-features=WebUIDarkMode --load-extension="${EXT_LIST}" "$@"
else
    exec /opt/helium-browser-bin/chrome --force-dark-mode --enable-features=WebUIDarkMode "$@"
fi
WRAPPEREOF
chmod +x "$HOME/.local/bin/helium-browser"

# Override system desktop entry so the wrapper is used
if [ -f /usr/share/applications/helium.desktop ]; then
    mkdir -p "$HOME/.local/share/applications"
    cp /usr/share/applications/helium.desktop "$HOME/.local/share/applications/helium.desktop"
    sed -i "s|^Exec=helium-browser|Exec=$HOME/.local/bin/helium-browser|g" "$HOME/.local/share/applications/helium.desktop"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Set Helium as the default browser and webapp handler
if command -v xdg-settings &>/dev/null; then
    xdg-settings set default-web-browser helium.desktop 2>/dev/null || true
    xdg-mime default helium.desktop x-scheme-handler/http 2>/dev/null || true
    xdg-mime default helium.desktop x-scheme-handler/https 2>/dev/null || true
    xdg-mime default helium.desktop text/html 2>/dev/null || true
fi

echo "[+] Helium setup completed!"
