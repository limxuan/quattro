#!/usr/bin/env bash
# Toggle between scrolling and dwindle layout

CURRENT=$(hyprctl getoption general:layout -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['str'])" 2>/dev/null || echo "dwindle")

if [ "$CURRENT" = "scrolling" ]; then
    hyprctl eval "hl.config({ general = { layout = 'dwindle' } })" >/dev/null 2>&1 || hyprctl keyword general:layout dwindle >/dev/null 2>&1
    omarchy-notification-send -g 󱂬 "Layout: dwindle" 2>/dev/null || true
    echo "Layout: dwindle"
else
    hyprctl eval "hl.config({ general = { layout = 'scrolling' } })" >/dev/null 2>&1 || hyprctl keyword general:layout scrolling >/dev/null 2>&1
    omarchy-notification-send -g 󱂬 "Layout: scrolling" 2>/dev/null || true
    echo "Layout: scrolling"
fi
