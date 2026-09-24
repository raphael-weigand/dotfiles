#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
    stand) height="58.51" ;;
    sit)   height="9.94" ;;
    high)  height="65.0" ;;
    *)
        echo "Usage: $0 {stand|sit|high}" >&2
        exit 2
        ;;
esac

# Detach the BLE desk command so callers (Hyprland/Quickshell) return immediately.
nohup /home/raphael/.local/bin/desk move-to "$height" >/dev/null 2>&1 &
