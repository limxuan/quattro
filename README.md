# Quattro — Omarchy 4.0 Dotfiles

Clean, declarative, and reproducible Arch Linux dotfiles built around **Omarchy 4.0** (Hyprland Lua + Quickshell), **Keyd** hardware remapping, and modern terminal tooling.

---

## ⚡ Quick Start

### Fresh System Install
```bash
git clone git@github.com:limxuan/quattro.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```
`install.sh` automatically installs Pacman/AUR packages, configures Keyd and libinput hardware quirks, sets up `ble.sh`/`tpm`/`sesh`, deploys webapps, and links all configurations.

### Sync Existing Configs
```bash
~/dotfiles/sync.sh
```
Safely symlinks all dotfiles to `~/.config/` and creates timestamped `.bak` copies of existing files.

---

## 🚀 Key Features

- **Hyprland (Lua-driven)**: Modular Omarchy 4.0 configuration (`bindings.lua`, `monitors.lua`, `looknfeel.lua`, `input.lua`, `autostart.lua`). Supports switching between dwindle and scrolling layouts on the fly.
- **Quickshell Bar**: Configured via `config/omarchy/shell.json` with system monitors, Tailscale status, battery indicators, media, and notification tray.
- **Keyd Keyboard Remap**: CapsLock mapped to `overload(meh, esc)` (`Meh = Ctrl+Alt+Shift` on hold, `Escape` on tap). Includes vim navigation (`H/J/K/L`), line deletion macros, and one-shot Shift.
- **Terminal & Shell**:
  - **Kitty**: Styled with Kanagawa Dragon color scheme and JetBrainsMono Nerd Font.
  - **Bash + ble.sh**: Real-time syntax highlighting, fish-like autosuggestions, and fuzzy history search.
  - **Starship Prompt**: Fast, minimalist git-aware status prompt.
  - **Shell Shortcuts**: `Ctrl+G` (edit current command line in Neovim), `Ctrl+S` (smart tmux attach/new).
- **Neovim**: Blazing fast configuration bootstrapped with `lazy.nvim`, `oil.nvim` (file manager), `telescope.nvim` (fuzzy find files & text), and `kanagawa.nvim`.
- **Tmux + Sesh**: Smart workspace-based session management (`open_ws`, `trs` reset), Vi copy mode, and `sesh` fuzzy session switcher.
- **AI Voice Dictation**: Hands-free voice-to-text powered by Groq Cloud (`whisper-large-v3`) via `Caps + E`.
- **Desktop & Web Apps**: Declarative webapp installer (`bin/apps.sh`), automatic Chromium extension policy manager, and Bitwarden integration.

---

## ⌨️ Keybindings Cheatsheet

### Keyd CapsLock (`Meh = Ctrl+Alt+Shift`)

| Shortcut | Action |
|---|---|
| `Caps + 1..9` | Switch to Workspace 1–9 |
| `Caps + Shift + 1..9` | Move window to Workspace 1–9 |
| `Caps + W` | Close active window |
| `Caps + X` | Switch to Workspace 6 |
| `Caps + R` / `Shift+R` | Toggle / Move window to scratchpad |
| `Caps + E` | Toggle Groq AI voice dictation |
| `Caps + B` | Toggle laptop trackpad |
| `Caps + D` | Smart clipboard paste |
| `Caps + F` | Maximize window (keep status bar visible) |
| `Caps + Space` | Clipboard manager |
| `Caps + T` / `G` | Toggle floating / window group |
| `Alt + Shift + X` | Move all windows to primary monitor |

### General & App Launchers

| Shortcut | Action |
|---|---|
| `Super + Return` | Launch Terminal (Kitty) |
| `Super + Alt + Return` | Open / Attach Work tmux session |
| `Super + Space` | Toggle layout (scrolling ↔ dwindle) |
| `Alt + Space` | Open application launcher menu |
| `Alt + Tab` | Interactive window switcher (`fzf`) |
| `Super + H/J/K/L` | Vim window focus (Left / Down / Up / Right) |
| `Super + X / C` | Cycle window focus Left / Right |
| `Super + Shift + Arrows` | Move window position |
| `Print` | Interactive screenshot capture & editor (Satty) |
| `Super + F` | File Manager (Nautilus) |
| `Super + B` | System Browser |
| `Super + M` | Spotify / Music |
| `Super + A` / `Shift+A` | AI Launchers (Gemini / Claude / Grok) |

---

## 📂 Repository Structure

```
├── bash/               # .bashrc and shell integration
├── bin/                # App declarations and Chromium/desktop setup scripts
├── config/
│   ├── fontconfig/     # Font rendering configurations
│   ├── hypr/           # Hyprland Lua configs and layout toggles
│   ├── kitty/          # Kitty terminal emulator config & Kanagawa palette
│   ├── nvim/           # Neovim init.lua and plugin lockfile
│   ├── omarchy/        # Quickshell bar and theme settings
│   ├── scripts/        # Utility scripts (Groq AI dictation, Satty, window switcher, SSH agent)
│   ├── tmux/           # Tmux configuration
│   ├── starship.toml   # Starship prompt configuration
│   └── xdg-terminals   # Default terminal priority
├── etc/
│   ├── keyd/           # Keyd layout configuration
│   └── libinput/       # Libinput quirk overrides
├── packages/           # Pacman and AUR explicit package manifests
├── install.sh          # Full automated environment bootstrap script
└── sync.sh             # Symlink deployment script with backup protection
```
