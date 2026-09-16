#!/usr/bin/env bash
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || exit 1
command -v jq >/dev/null 2>&1 || exit 1

workspace="$(hyprctl activeworkspace -j | jq -r '.id')"

# Gather windows from normal workspaces onto the currently active workspace.
# Special workspaces/scratchpads are deliberately left untouched.
mapfile -t addresses < <(
    hyprctl clients -j | jq -r --argjson workspace "$workspace" '
        .[]
        | select(.workspace.id > 0)
        | select(.workspace.id != $workspace)
        | .address
    '
)

for address in "${addresses[@]}"; do
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$address"
done
