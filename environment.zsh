#!/usr/bin/env zsh

# ============================================================================
# Environment Variables and PATH Configuration
# ============================================================================

# ============================================================================
# Editor Configuration
# ============================================================================

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='bat'

# ============================================================================
# Google chrome
# ============================================================================
export CHROME_EXECUTABLE="google-chrome-stable"

# ============================================================================
# PATH Configuration
# ============================================================================

# Helper function to prepend to PATH (add to start)
path_prepend() {
    # We use "${path[@]}" to expand the existing array cleanly
    [[ -d "$1" ]] && path=("$1" "${path[@]}")
}

# Helper function to append to PATH (add to end)
path_append() {
    # IMPORTANT: Parentheses ("$1") are required to add a NEW element
    [[ -d "$1" ]] && path+=("$1")
}

# Local binaries
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# Cargo (Rust)
path_prepend "$HOME/.cargo/bin"

# Go
path_append "/usr/local/go/bin"

# Python user binaries
path_append "$HOME/.local/share/python/bin"

# Flutter
path_append "$HOME/dev/sdks/flutter/bin"

# ============================================================================
# Tool Configuration
# ============================================================================

# ripgrep config file
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/ripgreprc"

# fzf default options
export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border
    --inline-info
    --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
    --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
    --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
    --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
"

# Use fd for fzf if available
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# bat theme
export BAT_THEME="ansi"

# less options
export LESS='-R -F -X -i -M -w -z-4'

# Colored man pages
export LESS_TERMCAP_mb=$'\e[1;31m'      # begin bold
export LESS_TERMCAP_md=$'\e[1;36m'      # begin blink
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\e[1;32m'      # begin underline
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline

# ============================================================================
# Language-specific Environment Variables
# ============================================================================

# Python
export PYTHONDONTWRITEBYTECODE=1

# Go
export GOPATH="${HOME}/dev/go"
export GOBIN="${GOPATH}/bin"
path_append "${GOBIN}"

# Node.js
export NODE_REPL_HISTORY="${XDG_DATA_HOME:-$HOME/.local/share}/node_repl_history"

# bun
export BUN_INSTALL="$HOME/.bun"
path_append "${BUN_INSTALL}/bin"

# android studio
path_append "${HOME}/dev/tools/android-studio/bin"

# ============================================================================
# XDG Base Directory Specification
# ============================================================================

export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ============================================================================
# Application-specific Cleanup
# ============================================================================

export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
export MYSQL_HISTFILE="${XDG_DATA_HOME}/mysql_history"
export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite_history"

# ============================================================================
# Zoxide Configuration
# ============================================================================
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"

    # Optional: Set zoxide data directory to XDG location
    export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"
    
    # Optional: Configure zoxide behavior
    # export _ZO_ECHO=1              # Print matched directory before navigating
    # export _ZO_EXCLUDE_DIRS=""     # Colon-separated list of dirs to exclude
    export _ZO_FZF_OPTS="
        --height=50%
	--border=rounded
	--preview='ls -lah {}'
	--preview-window='right:60%'
    " # Custom fzf options for zoxide
    # export _ZO_MAXAGE=10000        # Maximum age of entries in database
    # export _ZO_RESOLVE_SYMLINKS=0  # Don't resolve symlinks
fi

# Remove duplicates from PATH and rehash to update shell cache
typeset -U path
rehash
