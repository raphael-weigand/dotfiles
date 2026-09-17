#!/bin/sh

# Configure displays dynamically on the T2 MacBook. Connector names such as
# eDP-1/eDP-2 and DP-* are unstable, so identify outputs by runtime properties.

INTERNAL_DESCRIPTION="Apple Computer Inc Color LCD"
INTERNAL_DISPLAY="desc:$INTERNAL_DESCRIPTION"
INTERNAL_MODE="3072x1920@60, auto, 2"
EXTERNAL_MODE="preferred, auto, 1"

monitor_state() {
    hyprctl monitors all -j
}

is_phantom_filter='
    (.description // "") == ""
    and (.make // "") == ""
    and (.model // "") == ""
    and ((.availableModes // []) | length == 0)
'

disable_phantom_outputs() {
    monitor_state | jq -r ".[] | select($is_phantom_filter) | .name" |
        while IFS= read -r output; do
            [ -n "$output" ] || continue
            hyprctl keyword monitor "$output, disable"
        done
}

configure_external_displays() {
    # Any real display that is not the built-in Apple panel is external. Use the
    # runtime connector name only for this invocation; nothing is hardcoded.
    monitor_state | jq -r --arg internal "$INTERNAL_DESCRIPTION" ".[]
        | select(($is_phantom_filter) | not)
        | select((.description // \"\") != \$internal)
        | .name
    " | while IFS= read -r output; do
        [ -n "$output" ] || continue
        hyprctl keyword monitor "$output, $EXTERNAL_MODE"
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

lid_is_closed() {
    command -v evtest >/dev/null 2>&1 || return 2
    lid_device=$(find_lid_device) || return 2

    evtest --query "$lid_device" EV_SW SW_LID >/dev/null 2>&1
    case $? in
        10) return 0 ;;
        0)  return 1 ;;
        *)  return 2 ;;
    esac
}

configure_displays() {
    lid_state="$1"
    previous_workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')

    # Configure external outputs first so there is always a usable display while
    # the internal panel and any phantom connector are being adjusted.
    configure_external_displays
    disable_phantom_outputs

    case "$lid_state" in
        closed)
            hyprctl keyword monitor "$INTERNAL_DISPLAY, disable"
            ;;
        open)
            hyprctl keyword monitor "$INTERNAL_DISPLAY, $INTERNAL_MODE"
            ;;
        *)
            return 2
            ;;
    esac

    # Monitor changes can temporarily focus a newly-created empty workspace.
    # Return to the workspace that was active before reconfiguring, if it still exists.
    if [ -n "$previous_workspace" ] &&
       hyprctl workspaces -j | jq -e --argjson id "$previous_workspace" '.[] | select(.id == $id)' >/dev/null 2>&1; then
        hyprctl dispatch workspace "$previous_workspace"
    fi
}

sync_lid_state() {
    if lid_is_closed; then
        configure_displays closed
        return
    fi

    state=$?
    if [ "$state" -eq 1 ]; then
        configure_displays open
        return
    fi

    return 1
}

case "${1:-sync}" in
    closed)
        configure_displays closed
        ;;
    open)
        configure_displays open
        ;;
    sync)
        sync_lid_state
        ;;
    *)
        echo "Usage: $0 [open|closed|sync]" >&2
        exit 2
        ;;
esac
