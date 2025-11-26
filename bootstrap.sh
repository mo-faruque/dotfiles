#!/bin/bash
#
# Bootstrap script for setting up a new machine
# Usage: curl -fsSL https://raw.githubusercontent.com/mo-faruque/dotfiles/master/bootstrap.sh | bash
#

set -e

GITHUB_USER="mo-faruque"
DOTFILES_REPO="https://github.com/$GITHUB_USER/dotfiles.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Backup existing dotfiles
backup_dotfiles() {
    log_info "Backing up existing dotfiles..."
    mkdir -p "$BACKUP_DIR"

    local files_to_backup=(
        ".zshrc"
        ".bashrc"
        ".bash_profile"
        ".tmux.conf"
        ".gitconfig"
        ".p10k.zsh"
        ".config/nvim"
        ".config/starship.toml"
    )

    local backed_up=0
    for file in "${files_to_backup[@]}"; do
        if [ -e "$HOME/$file" ]; then
            cp -r "$HOME/$file" "$BACKUP_DIR/"
            ((backed_up++))
        fi
    done

    if [ $backed_up -gt 0 ]; then
        log_success "Backed up $backed_up files to $BACKUP_DIR"
    else
        log_info "No existing dotfiles to backup"
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif [ "$(uname)" == "Darwin" ]; then
        OS="macos"
    else
        OS="unknown"
    fi
    log_info "Detected OS: $OS"
}

# Install packages based on OS
install_packages() {
    log_info "Installing packages..."

    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y \
                git curl wget zsh tmux neovim \
                fzf ripgrep fd-find autojump \
                jq bat tldr gh
            ;;
        fedora)
            sudo dnf install -y \
                git curl wget zsh tmux neovim \
                fzf ripgrep fd-find autojump \
                jq bat tldr gh
            ;;
        arch)
            sudo pacman -Syu --noconfirm \
                git curl wget zsh tmux neovim \
                fzf ripgrep fd autojump \
                jq bat tldr github-cli eza
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install \
                git curl wget zsh tmux neovim \
                fzf ripgrep fd autojump \
                jq bat tldr gh eza lazygit yazi
            ;;
        *)
            log_warn "Unknown OS. Please install packages manually."
            ;;
    esac
    log_success "Packages installed"
}

# Install eza (modern ls)
install_eza() {
    if ! command -v eza &> /dev/null; then
        log_info "Installing eza..."
        case $OS in
            ubuntu|debian)
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                sudo apt update
                sudo apt install -y eza
                ;;
            *)
                log_warn "Install eza manually for your OS"
                ;;
        esac
        log_success "eza installed"
    else
        log_info "eza already installed"
    fi
}

# Install lazygit
install_lazygit() {
    if ! command -v lazygit &> /dev/null; then
        log_info "Installing lazygit..."
        case $OS in
            ubuntu|debian)
                LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                tar xf lazygit.tar.gz lazygit
                sudo install lazygit /usr/local/bin
                rm lazygit lazygit.tar.gz
                ;;
            *)
                log_warn "Install lazygit manually for your OS"
                ;;
        esac
        log_success "lazygit installed"
    else
        log_info "lazygit already installed"
    fi
}

# Install yazi (file manager)
install_yazi() {
    if ! command -v yazi &> /dev/null; then
        log_info "Installing yazi..."
        case $OS in
            ubuntu|debian)
                curl -Lo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
                unzip yazi.zip
                sudo install yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin
                rm -rf yazi.zip yazi-x86_64-unknown-linux-gnu
                ;;
            *)
                log_warn "Install yazi manually for your OS"
                ;;
        esac
        log_success "yazi installed"
    else
        log_info "yazi already installed"
    fi
}

# Install Zinit
install_zinit() {
    if [ ! -d "$HOME/.local/share/zinit" ]; then
        log_info "Installing Zinit..."
        bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" -- --skip-modify-rc
        log_success "Zinit installed"
    else
        log_info "Zinit already installed"
    fi
}

# Install Starship prompt
install_starship() {
    if ! command -v starship &> /dev/null; then
        log_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
        log_success "Starship installed"
    else
        log_info "Starship already installed"
    fi
}

# Install zoxide
install_zoxide() {
    if ! command -v zoxide &> /dev/null; then
        log_info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log_success "zoxide installed"
    else
        log_info "zoxide already installed"
    fi
}

# Install atuin
install_atuin() {
    if ! command -v atuin &> /dev/null; then
        log_info "Installing atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
        log_success "atuin installed"
    else
        log_info "atuin already installed"
    fi
}

# Install NVM
install_nvm() {
    if [ ! -d "$HOME/.nvm" ]; then
        log_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install 18
        nvm use 18
        log_success "NVM installed with Node 18"
    else
        log_info "NVM already installed"
    fi
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        log_success "TPM installed"
    else
        log_info "TPM already installed"
    fi
}

# Install chezmoi and apply dotfiles
install_chezmoi() {
    if ! command -v chezmoi &> /dev/null; then
        log_info "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
        log_success "chezmoi installed"
    else
        log_info "chezmoi already installed"
    fi

    log_info "Applying dotfiles..."
    ~/.local/bin/chezmoi init --apply $GITHUB_USER
    log_success "Dotfiles applied"
}

# Change default shell to zsh
change_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Changing default shell to zsh..."
        chsh -s $(which zsh)
        log_success "Default shell changed to zsh"
    else
        log_info "Shell is already zsh"
    fi
}

# Post-install setup
post_install() {
    log_info "Running post-install setup..."

    # Create local bin directory
    mkdir -p ~/.local/bin

    # Add to PATH if not already
    export PATH="$HOME/.local/bin:$PATH"

    # Install tmux plugins
    if [ -f ~/.tmux/plugins/tpm/bin/install_plugins ]; then
        log_info "Installing tmux plugins..."
        ~/.tmux/plugins/tpm/bin/install_plugins
    fi

    # Setup bat theme cache
    if command -v bat &> /dev/null; then
        bat cache --build 2>/dev/null || true
    fi

    log_success "Post-install setup complete"
}

# Main
main() {
    echo ""
    echo "=========================================="
    echo "  Dotfiles Bootstrap Script"
    echo "  github.com/$GITHUB_USER/dotfiles"
    echo "=========================================="
    echo ""

    detect_os
    backup_dotfiles
    install_packages
    install_eza
    install_lazygit
    install_yazi
    install_chezmoi
    install_zinit
    install_starship
    install_zoxide
    install_atuin
    install_nvm
    install_tpm
    change_shell
    post_install

    echo ""
    log_success "=========================================="
    log_success "  Setup complete!"
    log_success "=========================================="
    echo ""
    log_info "Installed tools:"
    echo "  - eza (ls replacement): ls, ll, la, lt"
    echo "  - bat (cat replacement): bat <file>"
    echo "  - lazygit: lg or lazygit"
    echo "  - yazi: yy (file manager)"
    echo "  - tldr: tldr <command>"
    echo "  - zoxide: z <directory>"
    echo "  - fzf: Ctrl+R (history), Ctrl+T (files)"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Run 'p10k configure' to setup Powerlevel10k"
    echo "  3. Open nvim and run ':Lazy sync' to install plugins"
    echo "  4. In tmux, press 'prefix + I' to install plugins"
    echo ""
}

main "$@"
