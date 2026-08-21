# Omarchy 4.0 Dotfiles

Clean, reproducible Arch Linux + Omarchy 4.0 (Hyprland Lua & Quickshell) dotfiles managed with standard Git and symlinks.

## Quick Start (Fresh System)

```bash
git clone https://github.com/limxuan/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## Updating / Syncing

Whenever you edit configurations directly in `~/.config/`, your changes are immediately live (via symlinks) and reflected in `~/dotfiles`.

To resync symlinks:
```bash
~/dotfiles/sync.sh
```

## Features

- **Hyprland (Lua)**: Modular Omarchy 4.0 Lua configuration (`bindings.lua`, `monitors.lua`, `looknfeel.lua`, `hyprland.lua`).
- **Status Bar (Quickshell)**: Managed natively via `~/.config/omarchy/shell.json` (Tailscale, battery power profile, system update, idle timers).
- **Keyd Keyboard Remapping**: CapsLock mapped to `overload(meh, esc)` (`meh` = `Ctrl+Alt+Shift`), Shift oneshot layer, vim navigation (`h/j/k/l`, `u/i`), line delete macro, and workspace switching.
- **Bash + ble.sh**: Rich syntax highlighting, auto-suggestions, fuzzy history completion, and keybindings (`Ctrl+G` to edit in nvim, `Ctrl+S` for tmux).
- **Tmux + Sesh**: Sesh fuzzy session switcher popup on `Alt+K`, resurrect, and TPM.
- **Kitty Terminal**: Kanagawa Dragon theme colors and JetBrainsMono Nerd Font.
- **Voice Dictation**: Voice dictation via Groq Cloud (`Caps + E`).
- **Helium Browser**: Unpacked extension loader wrapper script (`~/.local/bin/helium-browser`).

## Key Bindings

| Keybinding | Action |
|---|---|
| `Caps + 1..9` | Switch to workspace 1–9 |
| `Caps + Shift + 1..9` | Move active window to workspace 1–9 |
| `Caps + W` | Close active window |
| `Caps + X` | Switch to workspace 6 |
| `Caps + R` | Toggle scratchpad |
| `Caps + Shift + R` | Move window to scratchpad |
| `Caps + E` | Toggle Groq AI voice dictation |
| `Caps + B` | Toggle laptop trackpad |
| `Caps + D` | Smart clipboard paste |
| `Caps + F` | Toggle fullscreen |
| `Caps + Space` | Open clipboard manager |
| `Super + Return` | Open terminal (Kitty / Bash) |
| `Super + Alt + Return` | Open / attach Work tmux session |
| `Super + Space` | Toggle layout (scrolling ↔ dwindle) |
| `Super + H/J/K/L` | Vim window focus (Left / Down / Up / Right) |
| `Super + X / C` | Cycle focus left / right |
| `Print` | Capture & edit screenshot with Satty |
