#!/bin/bash
# Reconcile clamshell mode when DRM connector status changes.
# Polling is intentional: it also handles unplugging while the lid is closed.
set -u
SCRIPT="$HOME/.config/hypr/lid-display.sh"
last=""
while sleep 2; do
    state=$(for f in /sys/class/drm/card*-*/status; do
        [[ -r "$f" ]] || continue
        printf '%s=%s\n' "${f%/status}" "$(<"$f")"
    done | sort)
    if [[ "$state" != "$last" ]]; then
        last="$state"
        "$SCRIPT" sync >/dev/null 2>&1 || true
    fi
done
