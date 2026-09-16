#!/usr/bin/env bash
set -euo pipefail

choice="$(printf 'Lock\nLogout\nReboot\nShutdown\n' | fuzzel --dmenu --prompt='Power > ')"

case "$choice" in
    Lock)
        hyprlock
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
