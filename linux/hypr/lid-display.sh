#!/bin/sh

# Keep the internal MacBook display in sync with Hyprland's lid-switch events.
# On this T2 MacBook both GPUs expose an internal eDP connector. eDP-1 is the
# real Apple panel while eDP-2 is a mode-less phantom output. Disable both when
# the lid closes; when it opens, only enable the real Apple panel.

INTERNAL_DISPLAY="desc:Apple Computer Inc Color LCD"
INTERNAL_MODE="3072x1920@60, auto, 2"
PHANTOM_DISPLAY="eDP-2"

disable_internal_displays() {
    hyprctl keyword monitor "$PHANTOM_DISPLAY, disable"
    hyprctl keyword monitor "$INTERNAL_DISPLAY, disable"
}

enable_internal_display() {
    # Keep the phantom connector out of the Hyprland layout even with the lid open.
    hyprctl keyword monitor "$PHANTOM_DISPLAY, disable"
    hyprctl keyword monitor "$INTERNAL_DISPLAY, $INTERNAL_MODE"
}

case "${1:-}" in
    closed)
        disable_internal_displays
        ;;
    open)
        enable_internal_display
        ;;
    *)
        echo "Usage: $0 [open|closed]" >&2
        exit 2
        ;;
esac
