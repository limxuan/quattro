#!/usr/bin/env bash
set -euo pipefail

# sync-workspace-monitors.sh
# Ensures workspaces and windows are assigned to their designated monitors:
# - Workspaces 1-6 -> External monitor
# - Workspace 7    -> Internal monitor (eDP-1)
# If no external monitor is connected, all workspaces move to the internal display.

move_window() {
  local target_ws="$1"
  local addr="$2"
  hyprctl dispatch "hl.dsp.window.move({ workspace = '$target_ws', window = 'address:$addr', follow = false })" >/dev/null 2>&1 || \
  hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr" >/dev/null 2>&1
}

move_workspace() {
  local ws="$1"
  local monitor="$2"
  [ -z "$monitor" ] && return 0
  hyprctl dispatch "hl.dsp.workspace.move({ workspace = '$ws', monitor = '$monitor' })" >/dev/null 2>&1 || \
  hyprctl dispatch moveworkspacetomonitor "$ws $monitor" >/dev/null 2>&1
}

get_unused_workspace() {
  local used candidate=99
  used=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' 2>/dev/null || true)
  while grep -qx -- "$candidate" <<< "$used"; do
    candidate=$((candidate + 1))
  done
  echo "$candidate"
}

# 1. Detect monitors
MONITORS_JSON=$(hyprctl monitors -j 2>/dev/null)
if [ -z "$MONITORS_JSON" ] || [ "$MONITORS_JSON" = "[]" ]; then
  echo "Error: No active monitors detected from hyprctl." >&2
  exit 1
fi

INTERNAL_NAME=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)-")) | .name' | head -n 1)
INTERNAL_ID=$(echo "$MONITORS_JSON" | jq -r --arg name "$INTERNAL_NAME" '.[] | select(.name == $name) | .id')

EXTERNAL_NAME=$(echo "$MONITORS_JSON" | jq -r '.[] | select((.name | test("^(eDP|LVDS|DSI)-") | not) and .disabled == false) | .name' | head -n 1)
EXTERNAL_ID=$(echo "$MONITORS_JSON" | jq -r --arg name "$EXTERNAL_NAME" '.[] | select(.name == $name) | .id')

if [ -z "$INTERNAL_NAME" ] || [ "$INTERNAL_NAME" = "null" ]; then
  INTERNAL_NAME=$(echo "$MONITORS_JSON" | jq -r '.[0].name')
  INTERNAL_ID=$(echo "$MONITORS_JSON" | jq -r '.[0].id')
fi

HAS_EXTERNAL=false
if [ -n "$EXTERNAL_NAME" ] && [ "$EXTERNAL_NAME" != "null" ]; then
  HAS_EXTERNAL=true
  echo "Detected displays: Internal=$INTERNAL_NAME (ID $INTERNAL_ID), External=$EXTERNAL_NAME (ID $EXTERNAL_ID)"
else
  echo "Detected display: Internal=$INTERNAL_NAME (ID $INTERNAL_ID), No external monitor connected"
fi

TEMP_WS=$(get_unused_workspace)

# Helper to determine target monitor for a workspace
get_target_monitor_name() {
  local ws="$1"
  if [ "$HAS_EXTERNAL" = true ]; then
    if [ "$ws" -eq 7 ]; then
      echo "$INTERNAL_NAME"
    else
      echo "$EXTERNAL_NAME"
    fi
  else
    echo "$INTERNAL_NAME"
  fi
}

get_target_monitor_id() {
  local ws="$1"
  if [ "$HAS_EXTERNAL" = true ]; then
    if [ "$ws" -eq 7 ]; then
      echo "$INTERNAL_ID"
    else
      echo "$EXTERNAL_ID"
    fi
  else
    echo "$INTERNAL_ID"
  fi
}

# 2. Sync existing workspaces to target monitors
WORKSPACES_JSON=$(hyprctl workspaces -j 2>/dev/null || echo "[]")
for ws in 1 2 3 4 5 6 7; do
  TARGET_MON_NAME=$(get_target_monitor_name "$ws")
  CURRENT_MON=$(echo "$WORKSPACES_JSON" | jq -r --arg ws "$ws" '.[] | select((.id | tostring) == $ws or .name == $ws) | .monitor')

  if [ -n "$CURRENT_MON" ] && [ "$CURRENT_MON" != "null" ] && [ "$CURRENT_MON" != "$TARGET_MON_NAME" ]; then
    echo "Moving workspace $ws from $CURRENT_MON to $TARGET_MON_NAME..."
    move_workspace "$ws" "$TARGET_MON_NAME"
  fi
done

# 3. Check and sync all windows
CLIENTS_JSON=$(hyprctl clients -j 2>/dev/null || echo "[]")
echo "$CLIENTS_JSON" | jq -c '.[] | select(.mapped == true and .workspace.id > 0)' | while read -r client; do
  ADDR=$(echo "$client" | jq -r '.address')
  WS_ID=$(echo "$client" | jq -r '.workspace.id')
  CURRENT_MON_ID=$(echo "$client" | jq -r '.monitor')
  CLASS=$(echo "$client" | jq -r '.class')

  # Check workspaces 1-7
  if [ "$WS_ID" -ge 1 ] && [ "$WS_ID" -le 7 ]; then
    TARGET_MON_ID=$(get_target_monitor_id "$WS_ID")
    TARGET_MON_NAME=$(get_target_monitor_name "$WS_ID")

    if [ "$CURRENT_MON_ID" != "$TARGET_MON_ID" ]; then
      echo "Window '$CLASS' ($ADDR) on workspace $WS_ID is on monitor $CURRENT_MON_ID, moving to $TARGET_MON_NAME (ID $TARGET_MON_ID)..."
      # Bounce window through temporary workspace to ensure proper monitor re-mapping and geometry update
      move_window "$TEMP_WS" "$ADDR"
      sleep 0.03
      move_window "$WS_ID" "$ADDR"
    fi
  fi
done

# 4. Notify user
if [ "$HAS_EXTERNAL" = true ]; then
  MSG="Workspaces 1-6 → $EXTERNAL_NAME | Workspace 7 → $INTERNAL_NAME"
else
  MSG="All workspaces mapped to internal display ($INTERNAL_NAME)"
fi

if command -v omarchy-notification-send >/dev/null 2>&1; then
  omarchy-notification-send -g 󱂬 "Workspaces Synced" "$MSG" 2>/dev/null || true
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "Workspaces Synced" "$MSG" 2>/dev/null || true
fi

echo "Done. $MSG"
