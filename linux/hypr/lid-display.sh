#!/bin/bash
# Omarchy-inspired clamshell handling for the T2 MacBook.
# Identify the real internal panel by EDID, never by the first eDP connector.
set -u

INTERNAL_DESCRIPTION="Apple Computer Inc Color LCD"
INTERNAL_MODE="3072x1920@60, auto, 2"
EXTERNAL_MODE="preferred, auto, 1"

monitors() { hyprctl monitors all -j; }

internal_output() {
    monitors | jq -r --arg desc "$INTERNAL_DESCRIPTION"         '.[] | select(.description == $desc and (.availableModes | length > 0)) | .name' | head -n1
}

external_active() {
    monitors | jq -e --arg desc "$INTERNAL_DESCRIPTION"         'any(.[]; .disabled == false and .name != "FALLBACK" and .description != $desc and (.availableModes | length > 0))' >/dev/null
}

lid_closed() {
    local state
    for state in /proc/acpi/button/lid/*/state; do
        [[ -r "$state" ]] || continue
        grep -qi closed "$state" && return 0
        return 1
    done
    # logind tracks SW_LID and avoids evtest permissions and event-number guessing.
    [[ $(busctl --timeout=2 get-property org.freedesktop.login1 \
        /org/freedesktop/login1 org.freedesktop.login1.Manager LidClosed 2>/dev/null) == "b true" ]]
}

sync_displays() {
    local internal output
    internal=$(internal_output)
    [[ -n "$internal" && "$internal" =~ ^[A-Za-z0-9._-]+$ ]] || {
        echo "Real internal panel not found; leaving monitor state unchanged" >&2
        return 1
    }

    # Keep empty AMD phantom outputs disabled. The Lua startup detection
    # is still required before Hyprland allocates framebuffers.
    while IFS= read -r output; do
        [[ "$output" =~ ^[A-Za-z0-9._-]+$ ]] || continue
        hyprctl eval "hl.monitor({ output = \"$output\", disabled = true })" >/dev/null
    done < <(monitors | jq -r '.[] | select(.description == "" and .make == "" and .model == "" and (.availableModes | length == 0)) | .name')

    if [[ "${1:-sync}" == "closed" ]] && external_active || { [[ "${1:-sync}" == "sync" ]] && lid_closed && external_active; }; then
        hyprctl eval "hl.monitor({ output = \"$internal\", disabled = true })" >/dev/null
    else
        hyprctl eval "hl.monitor({ output = \"$internal\", mode = \"3072x1920@60\", position = \"auto\", scale = 2, disabled = false })" >/dev/null
    fi
}

case "${1:-sync}" in
    sync|open|closed) sync_displays "$1" ;;
    *) echo "Usage: $0 [sync|open|closed]" >&2; exit 2 ;;
esac
