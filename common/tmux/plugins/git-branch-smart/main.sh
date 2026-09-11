#!/bin/bash
cd "$1" 2>/dev/null

# Prüfe den aktuell aktiven Befehl im aktuellen TMUX Pane
current_prog=$(tmux display-message -p '#{pane_current_command}')

# Nur ausblenden wenn vim/nvim AKTIV im aktuellen Pane läuft
if [[ "$current_prog" == "vim" ]] || [[ "$current_prog" == "nvim" ]]; then
    exit 0
fi

# Git Branch anzeigen
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "[$branch]"
    fi
fi
