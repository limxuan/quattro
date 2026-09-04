#!/usr/bin/env bash

TYPES=$(wl-paste --list-types 2>/dev/null)

if [ -z "$TYPES" ]; then
    notify-send "📋 Clipboard" "Clipboard is empty" -i dialogue-warning -t 2000
    exit 0
fi

if echo "$TYPES" | grep -q "image/png"; then
    # Clipboard contains an image
    TMP=$(mktemp /tmp/clipXXXXXX.png)
    wl-paste --type image/png > "$TMP"

    # Calculate optimal window dimensions matching image aspect ratio and monitor size
    read -r WIN_W WIN_H ORIG_W ORIG_H < <(python3 -c "
import sys, json, subprocess, struct

img_w, img_h = 0, 0
try:
    with open(sys.argv[1], 'rb') as f:
        head = f.read(24)
        if head.startswith(b'\x89PNG\r\n\x1a\n'):
            img_w, img_h = struct.unpack('>II', head[16:24])
except Exception:
    pass

if not (img_w and img_h):
    try:
        out = subprocess.check_output(['identify', '-format', '%w %h', sys.argv[1]], stderr=subprocess.DEVNULL).decode()
        parts = out.strip().split()
        img_w, img_h = int(parts[0]), int(parts[1])
    except Exception:
        img_w, img_h = 800, 600

try:
    out = subprocess.check_output(['hyprctl', 'monitors', '-j'], stderr=subprocess.DEVNULL)
    mons = json.loads(out)
    mon = next((m for m in mons if m.get('focused')), mons[0])
    scale = mon.get('scale', 1.0)
    reserved = mon.get('reserved', [0, 0, 0, 0])
    screen_w = int(mon['width'] / scale)
    screen_h = int((mon['height'] - reserved[1] - reserved[3]) / scale)
except Exception:
    screen_w, screen_h = 1920, 1080

max_w = int(screen_w * 0.85)
max_h = int(screen_h * 0.85)
min_w, min_h = 320, 240

scale = min(max_w / img_w, max_h / img_h, 1.0)
win_w = int(img_w * scale)
win_h = int(img_h * scale)

if win_w < min_w or win_h < min_h:
    upscale = max(min_w / win_w, min_h / win_h)
    if int(win_w * upscale) <= max_w and int(win_h * upscale) <= max_h:
        win_w = int(win_w * upscale)
        win_h = int(win_h * upscale)

print(f'{win_w} {win_h} {img_w} {img_h}')
" "$TMP")

    # Spawn floating kitty terminal sized to image aspect ratio
    kitty --class=float-paste-image --title="Clipboard Image (${ORIG_W}x${ORIG_H})" \
        -o remember_window_size=no \
        -o initial_window_width="${WIN_W}" \
        -o initial_window_height="${WIN_H}" \
        -o window_padding_width=0 \
        bash -c "trap 'rm -f \"$TMP\"; tput cnorm 2>/dev/null' EXIT; \
                 tput civis 2>/dev/null; \
                 kitten icat --clear --align=center --fit=both --scale-up --no-trailing-newline \"$TMP\"; \
                 read -r -s -n 1" &
else
    # Clipboard contains text
    TMP=$(mktemp /tmp/clipXXXXXX.txt)
    wl-paste -n > "$TMP"

    # Spawn floating kitty terminal to show text with bat
    kitty --class=float-paste --title="Clipboard Note" bash -c \
        "trap 'rm -f \"$TMP\"' EXIT; \
         bat --style=plain --paging=always \"$TMP\"" &
fi
