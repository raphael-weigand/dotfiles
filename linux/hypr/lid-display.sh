#!/bin/sh

# Keep the internal MacBook display in sync with Hyprland's lid-switch events.
# This T2 MacBook exposes the real Apple panel plus a mode-less phantom eDP
# output. Connector names such as eDP-1/eDP-2 are assigned dynamically, so do
# not hardcode them.

INTERNAL_DISPLAY="desc:Apple Computer Inc Color LCD"
INTERNAL_MODE="3072x1920@60, auto, 2"

disable_phantom_edp_outputs() {
    # The phantom output has an eDP name but no make/model/description and no
    # available modes. Discover it from Hyprland's current monitor state.
    hyprctl monitors all -j | jq -r '
        .[]
        | select(.name | startswith("eDP-"))
        | select((.description // "") == "")
        | select((.make // "") == "")
        | select((.model // "") == "")
        | select((.availableModes // []) | length == 0)
        | .name
    ' | while IFS= read -r output; do
        [ -n "$output" ] || continue
        hyprctl keyword monitor "$output, disable"
    done
}

disable_internal_displays() {
    disable_phantom_edp_outputs
    hyprctl keyword monitor "$INTERNAL_DISPLAY, disable"
}

enable_internal_display() {
    # Keep any phantom eDP connector out of the layout even with the lid open.
    disable_phantom_edp_outputs
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
