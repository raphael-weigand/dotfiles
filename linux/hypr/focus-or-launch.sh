#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <class> <command> [args...]"
    exit 1
fi

CLASS="$1"
shift

if hyprctl clients -j | jq -e --arg class "$CLASS" \
    '.[] | select(.class == $class)' >/dev/null; then

    ESCAPED_CLASS="${CLASS//./\\.}"
    hyprctl dispatch focuswindow "class:^(${ESCAPED_CLASS})$"
else
    "$@" &
fi
