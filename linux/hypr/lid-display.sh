#!/bin/sh

# Keep the internal MacBook display in sync with the physical lid state.
# Connector names (eDP-1/eDP-2) and input event numbers are assigned dynamically,
# so identify devices by their runtime properties instead of hardcoding numbers.

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

find_lid_device() {
    for name_file in /sys/class/input/event*/device/name; do
        [ -r "$name_file" ] || continue
        [ "$(cat "$name_file")" = "Lid Switch" ] || continue
        event_name=$(basename "$(dirname "$(dirname "$name_file")")")
        printf '/dev/input/%s\n' "$event_name"
        return 0
    done
    return 1
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

sync_lid_state() {
    command -v evtest >/dev/null 2>&1 || return 1

    lid_device=$(find_lid_device) || return 1

    evtest --query "$lid_device" EV_SW SW_LID >/dev/null 2>&1
    state=$?

    case "$state" in
        10)
            disable_internal_displays
            ;;
        0)
            enable_internal_display
            ;;
        *)
            return 1
            ;;
    esac
}

case "${1:-sync}" in
    closed)
        disable_internal_displays
        ;;
    open)
        enable_internal_display
        ;;
    sync)
        sync_lid_state
        ;;
    *)
        echo "Usage: $0 [open|closed|sync]" >&2
        exit 2
        ;;
esac
