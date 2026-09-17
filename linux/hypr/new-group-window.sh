#!/usr/bin/env bash
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || exit 1
command -v jq >/dev/null 2>&1 || exit 1

active_window="$(hyprctl activewindow -j)"
pid="$(jq -r '.pid // empty' <<<"$active_window")"
address="$(jq -r '.address // empty' <<<"$active_window")"

[[ -n "$pid" && -n "$address" ]] || exit 1
[[ -e "/proc/$pid/exe" ]] || exit 1

executable="$(readlink -f "/proc/$pid/exe")"
[[ -x "$executable" ]] || exit 1

# Make the currently focused window the first member of a group when it is not
# grouped yet. Hyprland reports the group's member addresses in grouped[].
group_size="$(jq -r '(.grouped // []) | length' <<<"$active_window")"
if [[ "$group_size" -eq 0 ]]; then
    hyprctl dispatch togglegroup
fi

# Ask Hyprland to launch the same executable as the focused window. The
# "grouped" exec rule puts the newly created window into a group on creation.
# Because the current tile is already a group, normal group insertion rules
# make it join that group when it opens at the focused position.
hyprctl dispatch exec "[grouped] $executable"
