#!/usr/bin/env bash
set -euo pipefail

if pgrep -x quickshell >/dev/null 2>&1; then
    pkill -x quickshell
else
    quickshell >/tmp/quickshell-control-center.log 2>&1 &
fi
