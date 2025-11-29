#!/bin/bash
#
# Bootstrap script for setting up a new machine
#
# Usage (with sudo):
#   curl -fsSL https://raw.githubusercontent.com/mo-faruque/dotfiles/master/bootstrap.sh | bash
#
# Usage (without sudo - user-space only):
#   curl -fsSL https://raw.githubusercontent.com/mo-faruque/dotfiles/master/bootstrap.sh | bash -s -- --no-sudo
#
# Prerequisites for --no-sudo mode:
#   - git, curl, tar (must be installed on system)
#   - unzip, bzip2 (optional, for some tools)
#

set -e

GITHUB_USER="mo-faruque"

# Parse arguments
USER_MODE=false
for arg in "$@"; do
    case $arg in
        --no-sudo)
            USER_MODE=true
            shift
            ;;
    esac
done

# User-space directories
USER_BIN="$HOME/.local/bin"
USER_SHARE="$HOME/.local/share"

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
        *.tar.bz2|*.tbz)
            tar xjf "$filename"
            ;;
        *.zip)
            unzip -q "$filename"
            ;;
        *)
            chmod +x "$filename"
            mv "$filename" "$binary_name"
            ;;
    esac

    # Determine install location based on mode
    local install_dir="/usr/local/bin"
    local install_cmd="$SUDO install -m 755"
    if [ "$USER_MODE" = true ]; then
        install_dir="$USER_BIN"
        install_cmd="install -m 755"
        mkdir -p "$install_dir"
    fi

    # Find and install binary
    if [ -f "$extract_path" ]; then
        $install_cmd "$extract_path" "$install_dir/$binary_name"
    elif [ -f "$binary_name" ]; then
        $install_cmd "$binary_name" "$install_dir/$binary_name"
    else
        # Search for binary in extracted files
        local found_binary=$(find . -name "$binary_name" -type f -executable 2>/dev/null | head -1)
        if [ -n "$found_binary" ]; then
            $install_cmd "$found_binary" "$install_dir/$binary_name"
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
                fzf jq unzip \
                build-essential
            # Install neovim (may need PPA for latest)
            $SUDO apt install -y neovim || true
            ;;
        fedora)
            $SUDO dnf install -y \
                git curl wget zsh tmux \
                fzf jq unzip \
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
                fzf jq unzip
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                log_info "Installing Homebrew..."
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
            fi
            brew install \
                git curl wget zsh tmux neovim \
                fzf jq \
                eza bat fd ripgrep lazygit yazi gh tlrc btop fastfetch
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
        install_github_release "eza" "eza-community/eza" "x86_64-unknown-linux-musl.tar.gz" "eza"
    else
        install_github_release "eza" "eza-community/eza" "aarch64-unknown-linux-gnu.tar.gz" "eza"
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
        install_github_release "lazygit" "jesseduffield/lazygit" "linux_x86_64.tar.gz" "lazygit"
    else
        install_github_release "lazygit" "jesseduffield/lazygit" "linux_arm64.tar.gz" "lazygit"
    fi
}

# Install yazi (file manager) - GitHub binary
install_yazi() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "yazi" "sxyazi/yazi" "yazi-x86_64-unknown-linux-musl.zip" "yazi"
    else
        install_github_release "yazi" "sxyazi/yazi" "yazi-aarch64-unknown-linux-musl.zip" "yazi"
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

# Install btop (system monitor) - GitHub binary
install_btop() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "btop" "aristocratos/btop" "x86_64-linux-musl.tbz" "btop"
    else
        install_github_release "btop" "aristocratos/btop" "aarch64-linux-musl.tbz" "btop"
    fi
}

# Install fastfetch - GitHub binary
install_fastfetch() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "fastfetch" "fastfetch-cli/fastfetch" "linux-amd64.tar.gz" "fastfetch"
    else
        install_github_release "fastfetch" "fastfetch-cli/fastfetch" "linux-aarch64.tar.gz" "fastfetch"
    fi
}

# Install navi (interactive cheatsheet) - GitHub binary
install_navi() {
    [ "$OS" = "macos" ] && return 0

    if [ "$ARCH" = "x86_64" ]; then
        install_github_release "navi" "denisidoro/navi" "x86_64-unknown-linux-musl.tar.gz" "navi"
    else
        install_github_release "navi" "denisidoro/navi" "aarch64-unknown-linux-gnu.tar.gz" "navi"
    fi
}

# Install tldr (tlrc - Rust client) - GitHub binary
install_tldr() {
    [ "$OS" = "macos" ] && return 0

    if command -v tldr &> /dev/null; then
        log_info "tldr already installed"
        return 0
    fi

    # tlrc only provides x86_64 Linux binaries
    if [ "$ARCH" != "x86_64" ]; then
        log_warn "tldr (tlrc) not available for $ARCH - install manually via cargo or pip"
        return 0
    fi

    log_info "Installing tldr (tlrc) from GitHub..."

    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    local asset_url=$(curl -s "https://api.github.com/repos/tldr-pages/tlrc/releases/latest" | \
        grep -o '"browser_download_url": "[^"]*x86_64-unknown-linux-musl.tar.gz"' | \
        cut -d'"' -f4)

    if [ -z "$asset_url" ]; then
        log_warn "Could not find tlrc release"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi

    curl -sLO "$asset_url"
    tar xzf *.tar.gz

    # Install to appropriate location
    if [ "$USER_MODE" = true ]; then
        mkdir -p "$USER_BIN"
        install -m 755 tldr "$USER_BIN/tldr"
    else
        $SUDO install -m 755 tldr /usr/local/bin/tldr
    fi

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "tldr (tlrc) installed"
}

#############################################
# User-space installation functions (no sudo)
#############################################

# Install zsh from static binary (user mode)
install_zsh_user() {
    if command -v zsh &> /dev/null; then
        log_info "zsh already installed"
        return 0
    fi

    log_info "Installing zsh (user-space)..."

    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    # romkatv provides static zsh binaries
    if [ "$ARCH" = "x86_64" ]; then
        curl -sLo zsh.tar.gz "https://github.com/romkatv/zsh-bin/releases/download/v6.1.1/zsh-5.8-linux-x86_64.tar.gz"
    elif [ "$ARCH" = "aarch64" ]; then
        curl -sLo zsh.tar.gz "https://github.com/romkatv/zsh-bin/releases/download/v6.1.1/zsh-5.8-linux-aarch64.tar.gz"
    else
        log_error "No static zsh binary available for $ARCH"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi

    tar xzf zsh.tar.gz
    mkdir -p "$USER_BIN"
    # Find the zsh binary in extracted files
    local zsh_bin=$(find . -name "zsh" -type f -executable 2>/dev/null | head -1)
    if [ -n "$zsh_bin" ]; then
        cp "$zsh_bin" "$USER_BIN/zsh"
        chmod +x "$USER_BIN/zsh"
    else
        # Fallback: look in common locations
        cp ./bin/zsh "$USER_BIN/zsh" 2>/dev/null || cp ./zsh "$USER_BIN/zsh"
        chmod +x "$USER_BIN/zsh"
    fi

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "zsh installed to $USER_BIN"
}

# Install tmux from AppImage (extract binary, user mode)
install_tmux_user() {
    if command -v tmux &> /dev/null; then
        log_info "tmux already installed"
        return 0
    fi

    # Only x86_64 AppImage available
    if [ "$ARCH" != "x86_64" ]; then
        log_warn "tmux user-space install only available for x86_64"
        log_warn "Please ask system admin to install tmux"
        return 1
    fi

    log_info "Installing tmux (user-space)..."

    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    # Download AppImage and extract binary
    curl -sLo tmux.appimage "https://github.com/nelsonenzo/tmux-appimage/releases/download/3.5a/tmux.appimage"
    chmod +x tmux.appimage

    # Extract AppImage contents
    ./tmux.appimage --appimage-extract >/dev/null 2>&1

    mkdir -p "$USER_BIN"
    # Copy the tmux binary from squashfs-root
    if [ -f squashfs-root/usr/bin/tmux ]; then
        cp squashfs-root/usr/bin/tmux "$USER_BIN/tmux"
    elif [ -f squashfs-root/AppRun ]; then
        # Some AppImages have AppRun as the main executable
        cp squashfs-root/AppRun "$USER_BIN/tmux"
    else
        # Just use the AppImage directly
        cp tmux.appimage "$USER_BIN/tmux"
    fi
    chmod +x "$USER_BIN/tmux"

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "tmux installed to $USER_BIN"
}

# Install neovim from release binary (user mode)
install_neovim_user() {
    if command -v nvim &> /dev/null; then
        log_info "neovim already installed"
        return 0
    fi

    log_info "Installing neovim (user-space)..."

    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    if [ "$ARCH" = "x86_64" ]; then
        curl -sLo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        tar xzf nvim.tar.gz
        mkdir -p "$USER_BIN" "$USER_SHARE/nvim"
        # Copy entire nvim installation to user share
        cp -r nvim-linux-x86_64/* "$USER_SHARE/nvim/"
        ln -sf "$USER_SHARE/nvim/bin/nvim" "$USER_BIN/nvim"
    elif [ "$ARCH" = "aarch64" ]; then
        curl -sLo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        tar xzf nvim.tar.gz
        mkdir -p "$USER_BIN" "$USER_SHARE/nvim"
        cp -r nvim-linux-arm64/* "$USER_SHARE/nvim/"
        ln -sf "$USER_SHARE/nvim/bin/nvim" "$USER_BIN/nvim"
    else
        log_error "No neovim binary available for $ARCH"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "neovim installed to $USER_BIN"
}

# Install fzf binary + shell scripts (user mode)
install_fzf_user() {
    if command -v fzf &> /dev/null; then
        log_info "fzf already installed"
        return 0
    fi

    log_info "Installing fzf (user-space)..."

    local tmp_dir=$(mktemp -d)
    cd "$tmp_dir"

    # Get latest version dynamically
    local fzf_version=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)
    fzf_version=${fzf_version#v}  # Remove 'v' prefix if present

    if [ "$ARCH" = "x86_64" ]; then
        curl -sLo fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${fzf_version}/fzf-${fzf_version}-linux_amd64.tar.gz"
    elif [ "$ARCH" = "aarch64" ]; then
        curl -sLo fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${fzf_version}/fzf-${fzf_version}-linux_arm64.tar.gz"
    else
        log_error "No fzf binary available for $ARCH"
        cd - > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi

    tar xzf fzf.tar.gz
    mkdir -p "$USER_BIN"
    cp fzf "$USER_BIN/fzf"
    chmod +x "$USER_BIN/fzf"

    # Download fzf shell scripts for keybindings and completion
    mkdir -p "$USER_SHARE/fzf"
    curl -sLo "$USER_SHARE/fzf/key-bindings.zsh" "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
    curl -sLo "$USER_SHARE/fzf/completion.zsh" "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh"

    cd - > /dev/null
    rm -rf "$tmp_dir"
    log_success "fzf installed to $USER_BIN with shell scripts in $USER_SHARE/fzf"
}

# Check git availability (required for user mode)
check_git() {
    if command -v git &> /dev/null; then
        log_info "git available: $(git --version)"
        return 0
    fi

    log_error "git is required but not installed"
    log_error "Please ask your system administrator to install git"
    log_error "Or install via: apt install git / yum install git / etc."
    return 1
}

# Install base packages in user mode (no package manager)
install_base_packages_user() {
    log_info "Installing base packages (user-space mode)..."

    # Ensure user bin directory exists and is in PATH
    mkdir -p "$USER_BIN"
    export PATH="$USER_BIN:$PATH"

    # Check git is available (required for cloning repos)
    check_git || exit 1

    # Install core tools from static binaries
    install_zsh_user    # Shell
    install_tmux_user   # Terminal multiplexer
    install_neovim_user # Editor
    install_fzf_user    # Fuzzy finder

    log_success "Base packages installed (user-space)"
}

# Install Zinit
install_zinit() {
    if [ ! -d "$HOME/.local/share/zinit" ]; then
        log_info "Installing Zinit..."
        # Non-interactive install
        ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
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
    export NVM_DIR="$HOME/.nvm"

    if [ ! -d "$NVM_DIR" ]; then
        log_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    else
        log_info "NVM already installed"
    fi

    # Load NVM
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install Node 18 if not present
    if ! nvm ls 18 &>/dev/null; then
        log_info "Installing Node 18..."
        nvm install 18
    fi

    nvm use 18 --silent
    log_success "NVM ready with Node $(node -v)"
}

# Install Claude Code (uses official installer to create ~/.claude/local/claude)
install_claude_code() {
    if [ -f "$HOME/.claude/local/claude" ]; then
        log_info "Claude Code already installed"
        return 0
    fi

    log_info "Installing Claude Code..."

    # Ensure NVM and Node are loaded (installer requires Node.js)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use 18 --silent 2>/dev/null || true

    # Use official installer which creates ~/.claude/local/claude
    curl -fsSL https://claude.ai/install.sh | bash
    log_success "Claude Code installed"
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
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v chezmoi &> /dev/null; then
        log_info "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
        log_success "chezmoi installed"
    else
        log_info "chezmoi already installed"
    fi

    log_info "Applying dotfiles..."
    # Ensure XDG_RUNTIME_DIR is set correctly (fixes permission issues)
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
    mkdir -p "$XDG_RUNTIME_DIR" 2>/dev/null || true
    chezmoi init --apply $GITHUB_USER
    log_success "Dotfiles applied"
}

# Change default shell to zsh
change_shell() {
    local zsh_path=$(which zsh)

    if [ "$SHELL" = "$zsh_path" ]; then
        log_info "Shell is already zsh"
        return 0
    fi

    log_info "Changing default shell to zsh..."

    # Method 1: If running as root, use chsh directly
    if [ "$(id -u)" -eq 0 ]; then
        chsh -s "$zsh_path" && log_success "Default shell changed to zsh" && return 0
    fi

    # Method 2: Try sudo chsh (works if user has sudo without password for chsh)
    if $SUDO chsh -s "$zsh_path" "$(whoami)" 2>/dev/null; then
        log_success "Default shell changed to zsh"
        return 0
    fi

    # Method 3: Fallback - add exec zsh to .bashrc so bash auto-starts zsh
    if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
        log_warn "Could not change shell via chsh (requires password)"
        log_info "Adding 'exec zsh' to .bashrc as fallback..."
        echo '' >> "$HOME/.bashrc"
        echo '# Start zsh automatically' >> "$HOME/.bashrc"
        echo 'if [ -x "$(command -v zsh)" ]; then exec zsh; fi' >> "$HOME/.bashrc"
        log_success "Zsh will start automatically from bash"
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

    # Install neovim plugins (headless)
    if command -v nvim &> /dev/null; then
        log_info "Installing neovim plugins..."
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    fi

    # Fetch navi community cheats
    if command -v navi &> /dev/null; then
        if [ ! -d "$HOME/.local/share/navi/cheats/denisidoro__cheats" ]; then
            log_info "Fetching navi community cheats..."
            navi repo add denisidoro/cheats 2>/dev/null || true
        fi
    fi

    log_success "Post-install setup complete"
}

# Change shell to zsh (user mode - uses exec zsh in bashrc)
change_shell_user() {
    log_info "Setting up zsh as default shell (user mode)..."

    # In user mode, we can't use chsh, so we add exec zsh to .bashrc
    if ! grep -q "exec.*zsh" "$HOME/.bashrc" 2>/dev/null; then
        echo '' >> "$HOME/.bashrc"
        echo '# Start zsh automatically (user-space install)' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'if [ -x "$HOME/.local/bin/zsh" ]; then exec "$HOME/.local/bin/zsh"; fi' >> "$HOME/.bashrc"
        log_success "Zsh will start automatically from bash"
    else
        log_info "Zsh exec already configured in .bashrc"
    fi
}

# Main
main() {
    echo ""
    echo "=========================================="
    echo "  Dotfiles Bootstrap Script"
    echo "  github.com/$GITHUB_USER/dotfiles"
    if [ "$USER_MODE" = true ]; then
        echo "  Mode: User-space (no sudo)"
    fi
    echo "=========================================="
    echo ""

    detect_arch
    detect_os
    backup_dotfiles

    if [ "$USER_MODE" = true ]; then
        # User-space installation (no sudo required)
        log_info "Running in user-space mode (--no-sudo)"
        install_base_packages_user  # zsh, tmux, neovim, fzf, git
    else
        # Normal installation with package manager
        install_base_packages
    fi

    # These all support user mode via install_github_release
    install_eza
    install_bat
    install_fd
    install_ripgrep
    install_lazygit
    install_yazi
    install_gh
    install_btop
    install_fastfetch
    install_navi
    install_tpm
    install_chezmoi
    install_zinit
    install_zoxide
    install_atuin
    install_nvm
    install_claude_code
    install_tldr

    if [ "$USER_MODE" = true ]; then
        change_shell_user
    else
        change_shell
    fi

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
    echo "  - btop: system monitor"
    echo "  - fastfetch: system info"
    echo "  - tldr: tldr <command>"
    echo "  - zoxide: z <directory>"
    echo "  - fzf: Ctrl+R (history), Ctrl+T (files)"
    echo "  - claude: Claude Code AI assistant"
    echo ""
    if [ "$USER_MODE" = true ]; then
        log_info "User-space install location: $USER_BIN"
    fi
    log_info "Backup location: $BACKUP_DIR"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Run 'p10k configure' if prompt setup wizard appears"
    echo ""
}

main "$@"
