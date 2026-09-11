# Dotfiles

Shared and platform-specific development configuration.

## Layout

```text
common/          shared configuration used across supported systems
  git/
  nvim/
  tmux/
  vim/
  zsh/

macos/           macOS-only configuration
  aerospace/
  ghostty/

linux/           Linux-only configuration (when needed)
windows/         Windows/Visual Studio configuration
  vsvim/
  nppvim/
```

Neovim, tmux, zsh, Git and Vim live in `common/` so changes stay synchronized between macOS and Linux. Platform-specific applications stay outside `common/` and are only linked on the appropriate operating system.

## macOS / Linux installation

Clone the repository and run:

```bash
./install.sh
```

The installer detects macOS or Linux, installs the required development tools and creates symlinks to the shared configuration. Existing target files are backed up before a link is created.

On macOS the installer additionally links the Ghostty configuration. AeroSpace remains macOS-only but is not automatically linked yet.

On Debian-based Linux systems the installer installs the CLI development environment and Neovim, but does not install or link macOS-only applications such as Ghostty or AeroSpace.

## Windows

Windows-specific Vim integrations live below `windows/`. Visual Studio/VsVim and Notepad++/NppVim configuration can be managed there independently from the Unix installer.

A Windows installer will be added separately once those configurations are finalized.
