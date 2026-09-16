#!/usr/bin/env bash
set -euo pipefail

# Build a dynamic list of PipeWire output sinks. IDs are intentionally resolved
# at runtime because WirePlumber node IDs can change after reconnects/reboots.
mapfile -t sinks < <(
    wpctl status -n | awk '
        /Sinks:/ { in_sinks=1; next }
        in_sinks && /^[[:space:]]*[├└]─ Sources:/ { exit }
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

current_id="$(wpctl status -n | awk '
    /Sinks:/ { in_sinks=1; next }
    in_sinks && /^[[:space:]]*[├└]─ Sources:/ { exit }
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

# Move currently playing streams to the newly selected default when possible.
# New streams will automatically use the new default sink.
wpctl status -n >/dev/null
notify-send "Audio output" "${choice#● }"
