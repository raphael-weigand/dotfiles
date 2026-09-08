#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
ARCH="$(uname -m)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

log() {
    printf '\n==> %s\n' "$1"
}

backup_and_link() {
    local source="$1"
    local target="$2"

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        printf 'ok: %s\n' "$target"
        return
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.backup-${TIMESTAMP}"
        printf 'backup: %s -> %s\n' "$target" "$backup"
        mv "$target" "$backup"
    fi

    ln -s "$source" "$target"
    printf 'link: %s -> %s\n' "$target" "$source"
}

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        elif [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    log "Installing macOS development tools"
    brew install neovim tree-sitter tmux zsh-autosuggestions ripgrep fd
}

install_neovim_linux() {
    local archive

    case "$ARCH" in
        aarch64|arm64)
            archive="nvim-linux-arm64.tar.gz"
            ;;
        x86_64|amd64)
            archive="nvim-linux-x86_64.tar.gz"
            ;;
        *)
            printf 'Unsupported Linux architecture for Neovim binaries: %s\n' "$ARCH" >&2
            exit 1
            ;;
    esac

    log "Installing latest stable Neovim from the official release"

    local tmpdir
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    curl -fL "https://github.com/neovim/neovim/releases/latest/download/${archive}" -o "$tmpdir/nvim.tar.gz"
    tar -xzf "$tmpdir/nvim.tar.gz" -C "$tmpdir"

    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    rm -rf "$HOME/.local/opt/neovim"

    local extracted
    extracted="$(find "$tmpdir" -maxdepth 1 -type d -name 'nvim-linux-*' -print -quit)"
    mv "$extracted" "$HOME/.local/opt/neovim"
    ln -sfn "$HOME/.local/opt/neovim/bin/nvim" "$HOME/.local/bin/nvim"
}

version_ge() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

install_tree_sitter_linux() {
    local required="0.26.1"
    local current=""

    if command -v tree-sitter >/dev/null 2>&1; then
        current="$(tree-sitter --version 2>/dev/null | awk '{print $2}' | head -n1)"
    fi

    if [ -n "$current" ] && version_ge "$current" "$required"; then
        log "tree-sitter-cli $current already satisfies >= $required"
        return
    fi

    log "Installing current tree-sitter-cli (Debian's package is too old for nvim-treesitter main)"

    if ! command -v cargo >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
    fi

    # shellcheck disable=SC1091
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

    cargo install tree-sitter-cli --locked

    current="$("$HOME/.cargo/bin/tree-sitter" --version | awk '{print $2}' | head -n1)"
    if ! version_ge "$current" "$required"; then
        printf 'tree-sitter-cli installation failed: got %s, need >= %s\n' "$current" "$required" >&2
        exit 1
    fi
}

install_debian() {
    log "Installing Debian development tools"
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        git \
        pkg-config \
        ripgrep \
        tmux \
        trash-cli \
        zsh \
        zsh-autosuggestions

    mkdir -p "$HOME/.local/bin"
    if command -v fdfind >/dev/null 2>&1; then
        ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi

    install_neovim_linux
    install_tree_sitter_linux
}

install_linux() {
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
    fi

    if command -v apt-get >/dev/null 2>&1; then
        install_debian
    else
        printf 'Linux distribution is not supported automatically yet.\n' >&2
        exit 1
    fi
}

install_links() {
    log "Linking dotfiles"

    mkdir -p "$HOME/Programming" "$HOME/.config"

    backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    backup_and_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    backup_and_link "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

    if [ "$OS" = "Darwin" ]; then
        backup_and_link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
    fi

    if [ ! -d "$HOME/.config/tmux/plugins/tpm/.git" ]; then
        log "Installing tmux plugin manager"
        rm -rf "$HOME/.config/tmux/plugins/tpm"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
    fi
}

main() {
    case "$OS" in
        Darwin)
            install_macos
            ;;
        Linux)
            install_linux
            ;;
        *)
            printf 'Unsupported operating system: %s\n' "$OS" >&2
            exit 1
            ;;
    esac

    install_links

    log "Installed"
    printf 'OS:          %s\n' "$OS"
    printf 'Arch:        %s\n' "$ARCH"
    printf 'Neovim:      %s\n' "$(nvim --version | head -n1)"
    printf 'tree-sitter: %s\n' "$(tree-sitter --version)"
    printf 'tmux:        %s\n' "$(tmux -V)"
    printf '\nStart a new shell, then use: tmx\n'
}

main "$@"
