#!/usr/bin/env bash
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || exit 1
command -v jq >/dev/null 2>&1 || exit 1

# Move complete normal workspaces to the currently focused monitor instead of
# moving their individual windows into one workspace. This preserves each
# workspace's layout tree and avoids corrupting Dwindle state.
target_monitor="$(hyprctl activeworkspace -j | jq -r '.monitor')"

[[ -n "$target_monitor" && "$target_monitor" != "null" ]] || exit 1

mapfile -t workspaces < <(
    hyprctl workspaces -j | jq -r --arg monitor "$target_monitor" '
        .[]
        | select(.id > 0)
        | select(.monitor != $monitor)
        | .id
    ' | sort -n
)

for workspace in "${workspaces[@]}"; do
    hyprctl dispatch moveworkspacetomonitor "$workspace $target_monitor"
done
