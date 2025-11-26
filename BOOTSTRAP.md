# Bootstrap Script

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/mo-faruque/dotfiles/master/bootstrap.sh | bash
```

## What Gets Installed

- **eza, bat, fd, ripgrep** - Modern CLI replacements
- **fzf** - Fuzzy finder
- **lazygit** - Git TUI
- **yazi** - File manager
- **btop** - System monitor
- **zoxide** - Smart cd
- **atuin** - Shell history
- **zsh + Zinit + Powerlevel10k**
- **Neovim + LazyVim**
- **tmux + TPM**

## Post-Install

1. `exec zsh`
2. `p10k configure`
3. nvim: `:Lazy sync`
4. tmux: `prefix + I`

## Supported

Ubuntu, Debian, Fedora, Arch, openSUSE, macOS
