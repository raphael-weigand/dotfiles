#!/bin/bash
# install.sh - Richtet Dotfiles und Plugins ein

# Erstelle symbolische Links
echo "Erstelle symbolische Links..."
mkdir -p ~/.config/tmux
ln -sf ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf

# Installiere TPM, falls nicht vorhanden
TPM_DIR=~/.config/tmux/plugins/tpm
if [ ! -d "$TPM_DIR" ]; then
    echo "Installiere Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installiert in $TPM_DIR"
else
    echo "TPM ist bereits installiert."
fi

echo "Setup abgeschlossen!"
