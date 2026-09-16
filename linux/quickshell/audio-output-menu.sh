#!/usr/bin/env bash
set -euo pipefail

# Build a dynamic list of PipeWire output sinks. IDs are intentionally resolved
# at runtime because WirePlumber node IDs can change after reconnects/reboots.
# Use wpctl's human-readable output here: `-n` prints internal PipeWire node
# names such as alsa_output.pci-..., which are not useful in the UI.
mapfile -t sinks < <(
    wpctl status | awk '
        /Sinks:/ { in_sinks=1; next }
        in_sinks && /^[[:space:]│]*[├└]─ Sources:/ { exit }
        in_sinks {
            line=$0
            sub(/^[[:space:]│├└─*]+/, "", line)
            if (match(line, /^[0-9]+\./)) {
                id=substr(line, RSTART, RLENGTH-1)
                sub(/^[0-9]+\.[[:space:]]*/, "", line)
                sub(/[[:space:]]+\[vol:.*$/, "", line)
                print id "\t" line
            }
        }
    '
)

((${#sinks[@]})) || {
    notify-send "Audio" "No output devices found"
    exit 1
}

current_id="$(wpctl status | awk '
    /Sinks:/ { in_sinks=1; next }
    in_sinks && /^[[:space:]│]*[├└]─ Sources:/ { exit }
    in_sinks && /\*/ {
        line=$0
        sub(/^.*\*[[:space:]]*/, "", line)
        if (match(line, /^[0-9]+\./)) print substr(line, RSTART, RLENGTH-1)
        exit
    }
')"

menu=""
for sink in "${sinks[@]}"; do
    id="${sink%%$'\t'*}"
    name="${sink#*$'\t'}"
    marker="  "
    [[ "$id" == "$current_id" ]] && marker="● "
    menu+="${marker}${name}"$'\t'"${id}"$'\n'
done

choice="$(printf '%s' "$menu" | cut -f1 | fuzzel --dmenu --prompt='Output > ')" || exit 0
[[ -n "$choice" ]] || exit 0

selected_id="$(printf '%s' "$menu" | awk -F '\t' -v choice="$choice" '$1 == choice { print $2; exit }')"
[[ -n "$selected_id" ]] || exit 1

wpctl set-default "$selected_id"

# PipeWire/Pulse applications can keep an already-running stream attached to
# its old sink after the default changes. Move all current playback streams to
# the selected sink as well. A stream may disappear while iterating; that is a
# harmless race, so suppress that individual pactl error.
if command -v pactl >/dev/null 2>&1; then
    mapfile -t stream_ids < <(pactl list short sink-inputs 2>/dev/null | awk '{print $1}')
    for stream_id in "${stream_ids[@]}"; do
        [[ -n "$stream_id" ]] || continue
        pactl move-sink-input "$stream_id" "$selected_id" >/dev/null 2>&1 || true
    done
fi

notify-send "Audio output" "${choice#● }"
