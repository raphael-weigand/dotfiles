#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
ARCH="$(uname -m)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\n==> %s\n' "$1"; }

ensure_real_directory() {
    local dir="$1"
    if [ -L "$dir" ]; then
        local backup="${dir}.backup-${TIMESTAMP}"
        printf 'backup: %s -> %s\n' "$dir" "$backup"
        mv "$dir" "$backup"
    fi
    mkdir -p "$dir"
}

backup_and_link() {
    local source="$1" target="$2"
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
        if [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; elif [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    fi
    log "Installing macOS development tools"
    brew install neovim tree-sitter tmux zsh-autosuggestions ripgrep fd
}

install_neovim_linux() {
    local archive
    case "$ARCH" in
        aarch64|arm64) archive="nvim-linux-arm64.tar.gz" ;;
        x86_64|amd64) archive="nvim-linux-x86_64.tar.gz" ;;
        *) printf 'Unsupported Linux architecture for Neovim binaries: %s\n' "$ARCH" >&2; exit 1 ;;
    esac
    log "Installing latest stable Neovim from the official release"
    local tmpdir; tmpdir="$(mktemp -d)"
    trap 'rm -rf -- "${tmpdir:-}"' RETURN
    curl -fL "https://github.com/neovim/neovim/releases/latest/download/${archive}" -o "$tmpdir/nvim.tar.gz"
    tar -xzf "$tmpdir/nvim.tar.gz" -C "$tmpdir"
    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    rm -rf "$HOME/.local/opt/neovim"
    local extracted; extracted="$(find "$tmpdir" -maxdepth 1 -type d -name 'nvim-linux-*' -print -quit)"
    mv "$extracted" "$HOME/.local/opt/neovim"
    ln -sfn "$HOME/.local/opt/neovim/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf -- "$tmpdir"; trap - RETURN
}

version_ge() { printf '%s\n%s\n' "$2" "$1" | sort -V -C; }

install_tree_sitter_linux() {
    local required="0.26.1" current=""
    if command -v tree-sitter >/dev/null 2>&1; then current="$(tree-sitter --version 2>/dev/null | awk '{print $2}' | head -n1)"; fi
    if [ -n "$current" ] && version_ge "$current" "$required"; then log "tree-sitter-cli $current already satisfies >= $required"; return; fi
    log "Installing current tree-sitter-cli"
    if ! command -v cargo >/dev/null 2>&1; then curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal; fi
    # shellcheck disable=SC1091
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    cargo install tree-sitter-cli --locked
    current="$("$HOME/.cargo/bin/tree-sitter" --version | awk '{print $2}' | head -n1)"
    version_ge "$current" "$required" || { printf 'tree-sitter-cli installation failed\n' >&2; exit 1; }
}

install_debian() {
    log "Installing Debian development tools"
    sudo apt-get update
    sudo apt-get install -y build-essential ca-certificates curl fd-find git pkg-config ripgrep tmux trash-cli zsh zsh-autosuggestions
    mkdir -p "$HOME/.local/bin"
    if command -v fdfind >/dev/null 2>&1; then ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"; fi
    install_neovim_linux
    install_tree_sitter_linux
}

install_arch() {
    log "Installing Arch development and Hyprland desktop tools"
    sudo pacman -Syu --needed --noconfirm \
        base-devel curl git neovim tree-sitter-cli tmux zsh zsh-autosuggestions ripgrep fd trash-cli \
        hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt5-wayland qt6-wayland polkit-gnome \
        ghostty wl-clipboard waybar fuzzel mako libnotify hyprpaper hyprlock hypridle grim slurp cliphist \
        brightnessctl playerctl pavucontrol network-manager-applet bluez bluez-utils blueman \
        thunar tumbler ffmpegthumbnailer file-roller zathura zathura-pdf-mupdf \
        ttf-iosevka-nerd noto-fonts-emoji
    sudo systemctl enable --now bluetooth
}

install_linux() {
    if [ -r /etc/os-release ]; then # shellcheck disable=SC1091
        . /etc/os-release
    fi
    if command -v pacman >/dev/null 2>&1; then install_arch
    elif command -v apt-get >/dev/null 2>&1; then install_debian
    else printf 'Linux distribution is not supported automatically yet.\n' >&2; exit 1
    fi
}

install_t2_arch() {
    [ "$OS" = Linux ] || return
    [ -r /etc/os-release ] || return
    # shellcheck disable=SC1091
    . /etc/os-release
    [ "${ID:-}" = arch ] || return
    [ -e /sys/bus/pci/drivers/amdgpu/0000:03:00.0 ] || return

    log "Installing T2 AMDGPU stability service"
    sudo install -Dm644 "$DOTFILES_DIR/linux/systemd/amdgpu-t2-performance.service" /etc/systemd/system/amdgpu-t2-performance.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now amdgpu-t2-performance.service
}

install_links() {
    log "Linking common dotfiles"
    mkdir -p "$HOME/Programming" "$HOME/.config"
    backup_and_link "$DOTFILES_DIR/common/nvim" "$HOME/.config/nvim"
    ensure_real_directory "$HOME/.config/tmux"
    backup_and_link "$DOTFILES_DIR/common/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    backup_and_link "$DOTFILES_DIR/common/zsh/zshrc" "$HOME/.zshrc"

    # Ghostty uses the XDG config path on both Linux and macOS.
    # Keep the shared settings here so both platforms behave the same.
    ensure_real_directory "$HOME/.config/ghostty"
    backup_and_link "$DOTFILES_DIR/common/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
    [ ! -e "$HOME/.config/ghostty/config" ] && [ ! -L "$HOME/.config/ghostty/config" ] || rm -f "$HOME/.config/ghostty/config"

    if [ "$OS" = Darwin ]; then
        log "Linking macOS dotfiles"
        local dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
        ensure_real_directory "$dir"
        [ ! -e "$dir/config" ] && [ ! -L "$dir/config" ] || rm -f "$dir/config"
        backup_and_link "$DOTFILES_DIR/macos/ghostty/config.ghostty" "$dir/config.ghostty"
    elif [ "$OS" = Linux ]; then
        log "Linking Linux desktop dotfiles"
        backup_and_link "$DOTFILES_DIR/linux/hypr" "$HOME/.config/hypr"
        backup_and_link "$DOTFILES_DIR/linux/waybar" "$HOME/.config/waybar"
        backup_and_link "$DOTFILES_DIR/linux/mako" "$HOME/.config/mako"
    fi

    if [ ! -d "$HOME/.config/tmux/plugins/tpm/.git" ]; then
        log "Installing tmux plugin manager"
        rm -rf "$HOME/.config/tmux/plugins/tpm"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
    fi
}

main() {
    case "$OS" in Darwin) install_macos ;; Linux) install_linux ;; *) printf 'Unsupported operating system: %s\n' "$OS" >&2; exit 1 ;; esac
    install_links
    install_t2_arch
    log "Installed"
    printf 'OS: %s\nArch: %s\n' "$OS" "$ARCH"
    printf '\nStart a new shell, then use: tmx\n'
}

main "$@"
