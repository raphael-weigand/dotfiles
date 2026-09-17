#!/usr/bin/env bash

set -euo pipefail

# Dwindle stores three side-by-side tiles as nested splits rather than three
# independent columns. Resize both relevant split levels so the focused middle
# tile grows/shrinks from both sides while returning focus to the same tile.
case "${1:-}" in
    wider)
        hyprctl dispatch layoutmsg "splitratio -0.05"
        hyprctl dispatch movefocus r
        hyprctl dispatch layoutmsg "splitratio +0.1"
        hyprctl dispatch movefocus l
        ;;
    narrower)
        hyprctl dispatch layoutmsg "splitratio +0.05"
        hyprctl dispatch movefocus r
        hyprctl dispatch layoutmsg "splitratio -0.1"
        hyprctl dispatch movefocus l
        ;;
    *)
        echo "Usage: $0 {wider|narrower}" >&2
        exit 2
        ;;
esac
