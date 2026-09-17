#!/usr/bin/env bash

set -euo pipefail

STEP=60
HALF=$((STEP / 2))

case "${1:-}" in
    wider)
        hyprctl dispatch resizeactive "$STEP 0"
        hyprctl dispatch moveactive "-$HALF 0"
        ;;
    narrower)
        hyprctl dispatch resizeactive "-$STEP 0"
        hyprctl dispatch moveactive "$HALF 0"
        ;;
    *)
        echo "Usage: $0 {wider|narrower}" >&2
        exit 2
        ;;
esac
