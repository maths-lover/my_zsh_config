#!/usr/bin/env bash
# ============================================================================
# Cross-platform ZSH Bootstrap Script
# ============================================================================
# Clones this repo, installs dependencies, creates symlinks, and sets zsh
# as the default shell. Works on macOS (Apple Silicon / Intel) and Linux
# (Debian/Ubuntu, Fedora/RHEL, Arch).
#
# Usage:
#   git clone <repo> ~/.config/zsh && bash ~/.config/zsh/setup_zsh.sh
# ============================================================================

set -euo pipefail

# ============================================================================
# Resolve script location (works even when invoked via symlink)
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZDOTDIR="${SCRIPT_DIR}"
XDG_CONFIG_HOME="$(dirname "${ZDOTDIR}")"

# ============================================================================
# Logging helpers
# ============================================================================
info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
err()   { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
die()   { err "$@"; exit 1; }

# ============================================================================
# Phase 1 — Pre-flight checks
# ============================================================================
info "Pre-flight checks"

command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 \
    || die "curl or wget is required but neither is installed"

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    warn "Running as root — packages will install globally but symlinks target \$HOME"
fi

# ============================================================================
# Phase 2 — Platform detection
# ============================================================================
OS="$(uname -s)"
ARCH="$(uname -m)"
DISTRO=""
PKG=""

case "${OS}" in
    Darwin)
        info "Detected macOS (${ARCH})"
        PKG="brew"
        ;;
    Linux)
        if [[ -f /etc/os-release ]]; then
            # shellcheck disable=SC1091
            . /etc/os-release
            DISTRO="${ID}"
        fi
        case "${DISTRO}" in
            ubuntu|debian|pop|linuxmint|elementary|zorin)
                info "Detected Linux — ${PRETTY_NAME:-${DISTRO}} (apt)"
                PKG="apt"
                ;;
            fedora|rhel|centos|rocky|alma)
                info "Detected Linux — ${PRETTY_NAME:-${DISTRO}} (dnf)"
                PKG="dnf"
                ;;
            arch|manjaro|endeavouros)
                info "Detected Linux — ${PRETTY_NAME:-${DISTRO}} (pacman)"
                PKG="pacman"
                ;;
            *)
                die "Unsupported Linux distribution: ${DISTRO:-unknown}"
                ;;
        esac
        ;;
    *)
        die "Unsupported OS: ${OS}"
        ;;
esac

# ============================================================================
# Phase 3 — Package manager setup
# ============================================================================
install_pkg() {
    # Install one or more packages via the detected package manager.
    case "${PKG}" in
        brew)   brew install "$@" ;;
        apt)    sudo apt-get install -y "$@" ;;
        dnf)    sudo dnf install -y "$@" ;;
        pacman) sudo pacman -S --noconfirm --needed "$@" ;;
    esac
}

if [[ "${PKG}" == "brew" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        info "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Activate brew for the rest of this script
        if [[ "${ARCH}" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        ok "Homebrew already installed"
    fi
elif [[ "${PKG}" == "apt" ]]; then
    info "Updating apt package index"
    sudo apt-get update -qq
elif [[ "${PKG}" == "pacman" ]]; then
    info "Syncing pacman database"
    sudo pacman -Sy --noconfirm
fi

# ============================================================================
# Phase 4 — Install zsh
# ============================================================================
if ! command -v zsh >/dev/null 2>&1; then
    info "Installing zsh"
    install_pkg zsh
else
    ok "zsh already installed"
fi

# ============================================================================
# Phase 5 — Install CLI tools
# ============================================================================
info "Checking CLI tools"

# Each entry: "binary_name:brew_pkg:apt_pkg:dnf_pkg:pacman_pkg"
# Use "-" to skip a package manager (handled via fallback below)
TOOLS=(
    "bat:bat:bat:bat:bat"
    "eza:eza:-:-:eza"
    "fd:fd:fd-find:fd-find:fd"
    "fzf:fzf:fzf:fzf:fzf"
    "rg:ripgrep:ripgrep:ripgrep:ripgrep"
    "zoxide:zoxide:zoxide:zoxide:zoxide"
    "starship:starship:-:-:starship"
    "nvim:neovim:neovim:neovim:neovim"
    "fastfetch:fastfetch:-:fastfetch:fastfetch"
    "git:git:git:git:git"
    "tree:tree:tree:tree:tree"
)

pkg_field() {
    # Return the package name for the current PKG from a TOOLS entry
    local entry="$1"
    case "${PKG}" in
        brew)   echo "${entry}" | cut -d: -f2 ;;
        apt)    echo "${entry}" | cut -d: -f3 ;;
        dnf)    echo "${entry}" | cut -d: -f4 ;;
        pacman) echo "${entry}" | cut -d: -f5 ;;
    esac
}

install_starship() {
    if command -v starship >/dev/null 2>&1; then
        ok "starship already installed"
        return
    fi
    info "Installing starship via official installer"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
}

install_eza_apt() {
    if command -v eza >/dev/null 2>&1; then
        ok "eza already installed"
        return
    fi
    info "Installing eza from official apt repository"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y eza
}

install_eza_binary() {
    if command -v eza >/dev/null 2>&1; then
        ok "eza already installed"
        return
    fi
    info "Installing eza from GitHub release"
    local tmp
    tmp="$(mktemp -d)"
    local release_url="https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH}-unknown-linux-gnu.tar.gz"
    curl -fsSL "${release_url}" -o "${tmp}/eza.tar.gz" || {
        warn "Could not download eza binary — skipping"
        rm -rf "${tmp}"
        return
    }
    tar xzf "${tmp}/eza.tar.gz" -C "${tmp}"
    sudo install -m 755 "${tmp}/eza" /usr/local/bin/eza
    rm -rf "${tmp}"
}

install_fastfetch_apt() {
    if command -v fastfetch >/dev/null 2>&1; then
        ok "fastfetch already installed"
        return
    fi
    info "Installing fastfetch from GitHub release"
    local tmp
    tmp="$(mktemp -d)"
    local release_url="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${ARCH}.deb"
    curl -fsSL "${release_url}" -o "${tmp}/fastfetch.deb" || {
        warn "Could not download fastfetch .deb — skipping"
        rm -rf "${tmp}"
        return
    }
    sudo dpkg -i "${tmp}/fastfetch.deb" || sudo apt-get install -f -y
    rm -rf "${tmp}"
}

for entry in "${TOOLS[@]}"; do
    binary="${entry%%:*}"
    pkg_name="$(pkg_field "${entry}")"

    if command -v "${binary}" >/dev/null 2>&1; then
        ok "${binary} already installed"
        continue
    fi

    # Handle special cases where the package isn't in the default repos
    if [[ "${pkg_name}" == "-" ]]; then
        case "${binary}" in
            starship)   install_starship ;;
            eza)
                if [[ "${PKG}" == "apt" ]]; then
                    install_eza_apt
                elif [[ "${PKG}" == "dnf" ]]; then
                    install_eza_binary
                else
                    warn "No known method to install eza on ${PKG} — skipping"
                fi
                ;;
            fastfetch)
                if [[ "${PKG}" == "apt" ]]; then
                    install_fastfetch_apt
                else
                    warn "No known method to install fastfetch on ${PKG} — skipping"
                fi
                ;;
            *)
                warn "No package mapping for ${binary} on ${PKG} — skipping"
                ;;
        esac
        continue
    fi

    info "Installing ${binary} (${pkg_name})"
    install_pkg "${pkg_name}"
done

# Debian ships fd as fdfind — create alias symlink if needed
if [[ "${PKG}" == "apt" ]] && command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    info "Creating fd symlink for fdfind"
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# Debian ships bat as batcat — create alias symlink if needed
if [[ "${PKG}" == "apt" ]] && command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    info "Creating bat symlink for batcat"
    sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# ============================================================================
# Phase 6 — Install pyenv
# ============================================================================
if ! command -v pyenv >/dev/null 2>&1; then
    info "Installing pyenv"
    if [[ "${PKG}" == "brew" ]]; then
        brew install pyenv pyenv-virtualenv
    else
        # Install build dependencies for pyenv on Linux
        case "${PKG}" in
            apt)
                sudo apt-get install -y build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
                    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
                ;;
            dnf)
                sudo dnf install -y gcc make zlib-devel bzip2-devel \
                    readline-devel sqlite-devel openssl-devel tk-devel \
                    libffi-devel xz-devel
                ;;
            pacman)
                sudo pacman -S --noconfirm --needed base-devel openssl zlib \
                    bzip2 readline sqlite ncurses xz tk libffi
                ;;
        esac
        curl -fsSL https://pyenv.run | bash
    fi
else
    ok "pyenv already installed"
fi

# ============================================================================
# Phase 7 — Create directories
# ============================================================================
info "Ensuring directories exist"

dirs_to_create=(
    "${XDG_CONFIG_HOME}"
    "${HOME}/.local/bin"
    "${HOME}/.local/share"
    "${HOME}/.local/state"
    "${HOME}/.local/state/less"
    "${HOME}/.cache"
    "${ZDOTDIR}/completions"
    "${ZDOTDIR}/plugins"
    "${HOME}/.ssh"
)

for d in "${dirs_to_create[@]}"; do
    if [[ ! -d "${d}" ]]; then
        mkdir -p "${d}"
        ok "Created ${d}"
    fi
done

# Secure .ssh directory
chmod 700 "${HOME}/.ssh"

# ============================================================================
# Phase 8 — Create symlinks
# ============================================================================
info "Setting up symlinks"

safe_symlink() {
    local target="$1"  # the file in the repo
    local link="$2"    # where the symlink should live

    if [[ -L "${link}" ]]; then
        local current_target
        current_target="$(readlink "${link}")"
        if [[ "${current_target}" == "${target}" ]]; then
            ok "Symlink correct: ${link}"
            return
        else
            warn "Symlink ${link} points to ${current_target}, relinking to ${target}"
            rm "${link}"
        fi
    elif [[ -e "${link}" ]]; then
        warn "Backing up existing ${link} to ${link}.bak"
        mv "${link}" "${link}.bak"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "${link}")"
    ln -s "${target}" "${link}"
    ok "Linked ${link} -> ${target}"
}

safe_symlink "${ZDOTDIR}/.zshenv"       "${HOME}/.zshenv"
safe_symlink "${ZDOTDIR}/.zshrc"        "${HOME}/.zshrc"
safe_symlink "${ZDOTDIR}/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"

# For ripgrep, ensure the config directory exists
mkdir -p "${XDG_CONFIG_HOME}/ripgrep"
safe_symlink "${ZDOTDIR}/ripgrep/ripgreprc" "${XDG_CONFIG_HOME}/ripgrep/ripgreprc"

# ============================================================================
# Phase 9 — Install zsh plugins
# ============================================================================
info "Checking zsh plugins"

PLUGIN_DIR="${ZDOTDIR}/plugins"

clone_plugin() {
    local repo="$1"
    local name="$2"
    local dest="${PLUGIN_DIR}/${name}"

    if [[ -d "${dest}" ]]; then
        ok "Plugin ${name} already installed"
    else
        info "Cloning ${name}"
        git clone --depth 1 "${repo}" "${dest}"
        ok "Installed ${name}"
    fi
}

clone_plugin "https://github.com/zsh-users/zsh-autosuggestions"       zsh-autosuggestions
clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting"   zsh-syntax-highlighting
clone_plugin "https://github.com/Aloxaf/fzf-tab"                     fzf-tab
clone_plugin "https://github.com/lukechilds/zsh-nvm"                 zsh-nvm

# ============================================================================
# Phase 10 — SSH config
# ============================================================================
if [[ ! -f "${HOME}/.ssh/config" ]]; then
    info "Creating default ~/.ssh/config"
    if [[ "${OS}" == "Darwin" ]]; then
        cat > "${HOME}/.ssh/config" <<'SSH_EOF'
Host *
    AddKeysToAgent yes
    UseKeychain yes
SSH_EOF
    else
        cat > "${HOME}/.ssh/config" <<'SSH_EOF'
Host *
    AddKeysToAgent yes
SSH_EOF
    fi
    chmod 600 "${HOME}/.ssh/config"
    ok "Created ~/.ssh/config"
else
    ok "~/.ssh/config already exists — skipping"
    if [[ "${OS}" == "Linux" ]]; then
        if grep -q "UseKeychain" "${HOME}/.ssh/config" 2>/dev/null; then
            warn "~/.ssh/config contains 'UseKeychain' which is macOS-only"
            warn "Add 'IgnoreUnknown UseKeychain' before that line or remove it"
        fi
    fi
fi

# ============================================================================
# Phase 11 — Set default shell to zsh
# ============================================================================
ZSH_PATH="$(command -v zsh)"

if [[ "${SHELL}" == "${ZSH_PATH}" ]]; then
    ok "Default shell is already zsh"
else
    info "Setting default shell to zsh"

    # Add zsh to /etc/shells if not already listed (Linux)
    if [[ "${OS}" == "Linux" ]] && ! grep -qxF "${ZSH_PATH}" /etc/shells 2>/dev/null; then
        info "Adding ${ZSH_PATH} to /etc/shells"
        echo "${ZSH_PATH}" | sudo tee -a /etc/shells >/dev/null
    fi

    chsh -s "${ZSH_PATH}" || warn "chsh failed — you may need to change your shell manually"
fi

# ============================================================================
# Done
# ============================================================================
echo ""
ok "Setup complete!"
info "Open a new terminal or run: exec zsh -l"
