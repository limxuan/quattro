#!/usr/bin/env bash

# Move all windows across all workspaces to an unused workspace and back,
# ensuring every workspace and its windows are on the correct/active monitor.

move_window() {
  local target_ws="$1"
  local addr="$2"
  hyprctl dispatch "hl.dsp.window.move({ workspace = '$target_ws', window = 'address:$addr', follow = false })" >/dev/null 2>&1 || \
  hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr" >/dev/null 2>&1
}

move_workspace() {
  local ws="$1"
  local monitor="$2"
  [ -z "$monitor" ] && return
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

TARGET_MONITOR=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' 2>/dev/null)

# Find all workspaces that currently have mapped windows
WORKSPACES=$(hyprctl clients -j 2>/dev/null | jq -r \
  '.[] | select(.mapped == true and (.workspace.id > 0)) | .workspace.name // (.workspace.id | tostring)' | sort -u)

[ -z "$WORKSPACES" ] && exit 0

TARGET_WS=$(get_unused_workspace)

# Process each workspace
for ws in $WORKSPACES; do
  # Collect window addresses from this workspace
  WINDOWS=$(hyprctl clients -j 2>/dev/null | jq -r \
    ".[] | select((.workspace.name == \"$ws\" or (.workspace.id | tostring) == \"$ws\") and .mapped == true) | .address")
  
  # Skip if no windows in this workspace
  [ -z "$WINDOWS" ] && continue
  
  # Move workspace to target monitor if needed
  [ -n "$TARGET_MONITOR" ] && move_workspace "$ws" "$TARGET_MONITOR"
  
  # Move all windows in this workspace to unused workspace
  for addr in $WINDOWS; do
    move_window "$TARGET_WS" "$addr"
  done
  
  # Small delay to let Hyprland process moves
  sleep 0.05
  
  # Move them all back to their original workspace
  for addr in $WINDOWS; do
    move_window "$ws" "$addr"
  done
done
