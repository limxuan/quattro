#!/usr/bin/env bash
# Toggle between scrolling and dwindle layout

CURRENT=$(hyprctl getoption general:layout -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['str'])" 2>/dev/null || echo "scrolling")

if [ "$CURRENT" = "scrolling" ]; then
    hyprctl keyword general:layout dwindle >/dev/null 2>&1
    echo "Layout: dwindle"
else
    hyprctl keyword general:layout scrolling >/dev/null 2>&1
    echo "Layout: scrolling"
fi
