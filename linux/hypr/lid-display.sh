#!/bin/sh

# Keep the internal MacBook display in sync with the physical lid state.
# This is also run on every Hyprland config reload, because reloading the
# monitor rule can re-enable the panel without generating a new lid event.

INTERNAL_DISPLAY="desc:Apple Computer Inc Color LCD"
INTERNAL_MODE="3072x1920@60, auto, 2"

case "${1:-sync}" in
    closed)
        hyprctl keyword monitor "$INTERNAL_DISPLAY, disable"
        ;;
    open)
        hyprctl keyword monitor "$INTERNAL_DISPLAY, $INTERNAL_MODE"
        ;;
    sync)
        lid_state=""
        for state_file in /proc/acpi/button/lid/*/state; do
            [ -r "$state_file" ] || continue
            lid_state=$(awk '{print $2}' "$state_file")
            break
        done

        case "$lid_state" in
            closed)
                hyprctl keyword monitor "$INTERNAL_DISPLAY, disable"
                ;;
            open)
                hyprctl keyword monitor "$INTERNAL_DISPLAY, $INTERNAL_MODE"
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 [open|closed|sync]" >&2
        exit 2
        ;;
esac
