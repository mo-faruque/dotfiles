# Bootstrap Script

## Quick Install

```bash
# With sudo (system-wide)
curl -fsSL https://raw.githubusercontent.com/mo-faruque/dotfiles/master/bootstrap.sh | bash

# Without sudo (user-space only)
curl -fsSL https://raw.githubusercontent.com/mo-faruque/dotfiles/master/bootstrap.sh | bash -s -- --no-sudo
```

## What Gets Installed

- **zsh, tmux, neovim** - Shell, multiplexer, editor
- **eza, bat, fd, ripgrep** - Modern CLI replacements
- **fzf** - Fuzzy finder (Ctrl+T files, Alt+C dirs)
- **lazygit** - Git TUI
- **yazi** - File manager
- **btop, fastfetch** - System monitor & info
- **zoxide** - Smart cd
- **atuin** - Shell history
- **gh, tldr, navi** - GitHub CLI, cheatsheets (Ctrl+G)
- **Zinit + Powerlevel10k** - Zsh plugins
- **LazyVim** - Neovim config
- **TPM** - Tmux plugin manager

## --no-sudo Mode

Installs everything to `~/.local/bin/` without root privileges.

**Prerequisites:** git, curl, tar must be available on the system.

**How it works:**
- Downloads static binaries for zsh, tmux, neovim, fzf
- All tools installed to `~/.local/bin/`
- Adds `exec zsh` to `.bashrc` (can't use chsh without sudo)

## Post-Install

1. `exec zsh`
2. `p10k configure`
3. nvim: `:Lazy sync`
4. tmux: `prefix + I`

## Supported

Ubuntu, Debian, Fedora, Arch, openSUSE, macOS
