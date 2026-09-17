#!/usr/bin/env bash
set -euo pipefail

config="$HOME/.config/quickshell/localsend"

if pgrep -f "quickshell.*${config}" >/dev/null 2>&1; then
    pkill -f "quickshell.*${config}"
else
    quickshell -p "$config" >/tmp/quickshell-localsend.log 2>&1 &
fi
