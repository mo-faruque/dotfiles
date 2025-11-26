# Dotfiles

My dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## What's Included

- `zshrc` - Zsh config with Zinit, Powerlevel10k
- `tmux.conf` - Tmux config with TPM
- `p10k.zsh` - Powerlevel10k theme
- `starship.toml` - Starship prompt config
- `gitconfig` - Git configuration

## Quick Start (New Machine)

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mo-faruque
```

## Manual Setup

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Initialize with this repo
chezmoi init https://github.com/mo-faruque/dotfiles.git

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply
```

## Daily Usage

### Edit a dotfile
```bash
# Option 1: Edit directly, then add
vim ~/.zshrc
chezmoi add ~/.zshrc

# Option 2: Edit through chezmoi (auto-applies on save)
chezmoi edit ~/.zshrc
```

### Push changes
```bash
chezmoi cd
git add .
git commit -m "Update zshrc"
git push
```

### Pull changes on another machine
```bash
chezmoi update
```

## Useful Commands

| Command | Description |
|---------|-------------|
| `chezmoi add <file>` | Add a dotfile to chezmoi |
| `chezmoi edit <file>` | Edit a dotfile |
| `chezmoi diff` | Preview pending changes |
| `chezmoi apply` | Apply changes to home directory |
| `chezmoi update` | Pull from remote and apply |
| `chezmoi cd` | Go to chezmoi source directory |
| `chezmoi data` | Show template data (hostname, OS, etc.) |

## Machine-Specific Configs

Use templates for different machines. Rename file with `.tmpl`:

```bash
chezmoi add --template ~/.zshrc
chezmoi edit ~/.zshrc
```

Then use conditionals:
```bash
{{ if eq .chezmoi.hostname "work-laptop" }}
export WORK_VAR="value"
{{ end }}
```

## Dependencies

After applying dotfiles, install:

```bash
# Zsh plugins (Zinit installs automatically)
# TPM plugins
~/.tmux/plugins/tpm/bin/install_plugins

# Other tools
# - zoxide: https://github.com/ajeetdsouza/zoxide
# - atuin: https://github.com/atuinsh/atuin
# - starship: https://starship.rs
```
