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

# Use sudo only if not root
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Detect architecture
detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="x86_64" ; ARCH_ALT="amd64" ;;
        aarch64|arm64) ARCH="aarch64" ; ARCH_ALT="arm64" ;;
        *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
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
    log_info "Detected OS: $OS ($ARCH)"
}

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
            backed_up=$((backed_up + 1))
        fi
    done

    if [ $backed_up -gt 0 ]; then
        log_success "Backed up $backed_up files to $BACKUP_DIR"
    else
        log_info "No existing dotfiles to backup"
    fi
}

# Helper: Install from GitHub release (binary)
install_github_release() {
    local name=$1
    local repo=$2
    local asset_pattern=$3
    local binary_name=${4:-$name}
    local extract_path=${5:-$binary_name}

    if command -v "$binary_name" &> /dev/null; then
        log_info "$name already installed"
        return 0
    fi

    log_info "Installing $name from GitHub..."

    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    # Get latest release asset URL
    local asset_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | \
        grep -o "\"browser_download_url\": \"[^\"]*${asset_pattern}[^\"]*\"" | \
        head -1 | cut -d'"' -f4)

    if [ -z "$asset_url" ]; then
        log_warn "Could not find release for $name"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi

    local filename=$(basename "$asset_url")
    curl -sLO "$asset_url"

    # Extract based on file type
    case "$filename" in
        *.tar.gz|*.tgz)
            tar xzf "$filename"
            ;;
        *.zip)
            unzip -q "$filename"
            ;;
        *)
            chmod +x "$filename"
            mv "$filename" "$binary_name"
            ;;
    esac

    # Find and install binary
    if [ -f "$extract_path" ]; then
        $SUDO install -m 755 "$extract_path" /usr/local/bin/"$binary_name"
    elif [ -f "$binary_name" ]; then
        $SUDO install -m 755 "$binary_name" /usr/local/bin/"$binary_name"
    else
        # Search for binary in extracted files
        local found_binary=$(find . -name "$binary_name" -type f -executable 2>/dev/null | head -1)
        if [ -n "$found_binary" ]; then
            $SUDO install -m 755 "$found_binary" /usr/local/bin/"$binary_name"
        else
            log_warn "Could not find $binary_name binary"
            cd - > /dev/null
            rm -rf "$tmp_dir"
            return 1
        fi
    fi

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "$name installed"
}

# Install basic packages via package manager
install_base_packages() {
    log_info "Installing base packages..."

    case $OS in
        ubuntu|debian)
            $SUDO apt update
            $SUDO apt install -y \
                git curl wget zsh tmux \
                fzf autojump jq unzip \
                build-essential
            # Install neovim (may need PPA for latest)
            $SUDO apt install -y neovim || true
            ;;
        fedora)
            $SUDO dnf install -y \
                git curl wget zsh tmux \
                fzf autojump jq unzip \
                neovim
            ;;
        centos|rhel|rocky|alma)
            $SUDO yum install -y epel-release || true
            $SUDO yum install -y \
                git curl wget zsh tmux \
                fzf jq unzip
            # neovim might need additional repo
            $SUDO yum install -y neovim || log_warn "Install neovim manually"
            ;;
        arch|manjaro)
            $SUDO pacman -Syu --noconfirm \
                git curl wget zsh tmux neovim \
                fzf jq unzip base-devel
            # autojump is in AUR, skipping - use zoxide instead
            ;;
        opensuse*)
            $SUDO zypper install -y \
                git curl wget zsh tmux neovim \
                fzf autojump jq unzip
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
            fi
            brew install \
                git curl wget zsh tmux neovim \
                fzf autojump jq \
                eza bat fd ripgrep lazygit yazi gh tldr
            ;;
        *)
            log_warn "Unknown OS: $OS. Installing minimal packages..."
            ;;
    esac
    log_success "Base packages installed"
}

# Install eza (modern ls) - GitHub binary
install_eza() {
    [ "$OS" = "macos" ] && return 0  # Already installed via brew

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "eza" "eza-community/eza" "linux-x86_64-musl.tar.gz" "eza"
    else
        install_github_release "eza" "eza-community/eza" "linux-aarch64.tar.gz" "eza"
    fi
}

# Install bat (modern cat) - GitHub binary
install_bat() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "bat" "sharkdp/bat" "x86_64-unknown-linux-musl.tar.gz" "bat"
    else
        install_github_release "bat" "sharkdp/bat" "aarch64-unknown-linux-gnu.tar.gz" "bat"
    fi
}

# Install fd (modern find) - GitHub binary
install_fd() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "fd" "sharkdp/fd" "x86_64-unknown-linux-musl.tar.gz" "fd"
    else
        install_github_release "fd" "sharkdp/fd" "aarch64-unknown-linux-gnu.tar.gz" "fd"
    fi
}

# Install ripgrep - GitHub binary
install_ripgrep() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "ripgrep" "BurntSushi/ripgrep" "x86_64-unknown-linux-musl.tar.gz" "rg"
    else
        install_github_release "ripgrep" "BurntSushi/ripgrep" "aarch64-unknown-linux-gnu.tar.gz" "rg"
    fi
}

# Install lazygit - GitHub binary
install_lazygit() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "lazygit" "jesseduffield/lazygit" "Linux_x86_64.tar.gz" "lazygit"
    else
        install_github_release "lazygit" "jesseduffield/lazygit" "Linux_arm64.tar.gz" "lazygit"
    fi
}

# Install yazi (file manager) - GitHub binary
install_yazi() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "yazi" "sxyazi/yazi" "x86_64-unknown-linux-musl.zip" "yazi"
    else
        install_github_release "yazi" "sxyazi/yazi" "aarch64-unknown-linux-musl.zip" "yazi"
    fi
}

# Install GitHub CLI - GitHub binary
install_gh() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "gh" "cli/cli" "linux_amd64.tar.gz" "gh"
    else
        install_github_release "gh" "cli/cli" "linux_arm64.tar.gz" "gh"
    fi
}

# Install tldr - npm or binary
install_tldr() {
    [ "$OS" = "macos" ] && return 0

    if command -v tldr &> /dev/null; then
        log_info "tldr already installed"
        return 0
    fi

    # Try npm first if available
    if command -v npm &> /dev/null; then
        log_info "Installing tldr via npm..."
        npm install -g tldr
        log_success "tldr installed"
    else
        log_warn "Install tldr after NVM setup: npm install -g tldr"
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

# Install zoxide - official installer
install_zoxide() {
    if ! command -v zoxide &> /dev/null; then
        log_info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log_success "zoxide installed"
    else
        log_info "zoxide already installed"
    fi
}

# Install atuin - official installer
install_atuin() {
    if ! command -v atuin &> /dev/null; then
        log_info "Installing atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
        log_success "atuin installed"
    else
        log_info "atuin already installed"
    fi
}

# Install NVM and Node
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
        chsh -s $(which zsh) || log_warn "Could not change shell. Run: chsh -s \$(which zsh)"
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
        ~/.tmux/plugins/tpm/bin/install_plugins || true
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

    detect_arch
    detect_os
    backup_dotfiles
    install_base_packages
    install_eza
    install_bat
    install_fd
    install_ripgrep
    install_lazygit
    install_yazi
    install_gh
    install_chezmoi
    install_zinit
    install_zoxide
    install_atuin
    install_nvm
    install_tldr
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
    echo "  - fd (find replacement): fd <pattern>"
    echo "  - rg (grep replacement): rg <pattern>"
    echo "  - lazygit: lg or lazygit"
    echo "  - yazi: yy (file manager)"
    echo "  - gh: GitHub CLI"
    echo "  - tldr: tldr <command>"
    echo "  - zoxide: z <directory>"
    echo "  - fzf: Ctrl+R (history), Ctrl+T (files)"
    echo ""
    log_info "Backup location: $BACKUP_DIR"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Run 'p10k configure' to setup Powerlevel10k"
    echo "  3. Open nvim and run ':Lazy sync' to install plugins"
    echo "  4. In tmux, press 'prefix + I' to install plugins"
    echo ""
}

main "$@"
