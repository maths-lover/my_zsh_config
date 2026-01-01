#!/usr/bin/env zsh
# ============================================================================
# Manual Plugin Management (No Plugin Manager)
# ============================================================================

# Plugin directory
PLUGIN_DIR="${ZDOTDIR}/plugins"

# Create plugin directory if it doesn't exist
[[ ! -d "$PLUGIN_DIR" ]] && mkdir -p "$PLUGIN_DIR"

# ============================================================================
# Plugin Installation Instructions
# ============================================================================

# To install plugins manually, run these commands:
#
# 1. zsh-autosuggestions:
#    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZDOTDIR}/plugins/zsh-autosuggestions
#
# 2. zsh-syntax-highlighting:
#    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZDOTDIR}/plugins/zsh-syntax-highlighting
#
# 3. fzf-tab (optional but recommended):
#    git clone https://github.com/Aloxaf/fzf-tab ${ZDOTDIR}/plugins/fzf-tab
#
# To update plugins, cd into each plugin directory and run: git pull

# ============================================================================
# Helper Functions
# ============================================================================

# Function to source plugin if it exists
load_plugin() {
    local plugin_name="$1"
    local plugin_file="$2"
    local plugin_path="${PLUGIN_DIR}/${plugin_name}/${plugin_file}"
    
    if [[ -f "$plugin_path" ]]; then
        source "$plugin_path"
    else
        echo "Plugin not found: ${plugin_name}"
        echo "Install it with: git clone https://github.com/zsh-users/${plugin_name} ${PLUGIN_DIR}/${plugin_name}"
    fi
}

# Function to install plugins
install_plugins() {
    echo "Installing ZSH plugins..."
    
    # Install zsh-autosuggestions
    if [[ ! -d "${PLUGIN_DIR}/zsh-autosuggestions" ]]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "${PLUGIN_DIR}/zsh-autosuggestions"
    else
        echo "✓ zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [[ ! -d "${PLUGIN_DIR}/zsh-syntax-highlighting" ]]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "${PLUGIN_DIR}/zsh-syntax-highlighting"
    else
        echo "✓ zsh-syntax-highlighting already installed"
    fi
    
    # Install fzf-tab (optional)
    if [[ ! -d "${PLUGIN_DIR}/fzf-tab" ]]; then
        echo "Installing fzf-tab..."
        git clone https://github.com/Aloxaf/fzf-tab "${PLUGIN_DIR}/fzf-tab"
    else
        echo "✓ fzf-tab already installed"
    fi

    # Install zsh-nvm for node version manager (nvm) (optional)
    if [[ ! -d "${PLUGIN_DIR}/zsh-nvm" ]]; then
        echo "Installing zsh-nvm..."
        git clone https://github.com/lukechilds/zsh-nvm.git "${PLUGIN_DIR}/zsh-nvm"
    else
        echo "✓ zsh-nvm already installed"
    fi
    
    echo ""
    echo "✓ Plugin installation complete!"
    echo "Please reload your shell: source ${ZDOTDIR}/.zshrc"
}

# Function to update all plugins
update_plugins() {
    echo "Updating ZSH plugins..."
    
    for plugin in "${PLUGIN_DIR}"/*; do
        if [[ -d "$plugin/.git" ]]; then
            echo "Updating $(basename $plugin)..."
            (cd "$plugin" && git pull)
        fi
    done
    
    echo ""
    echo "✓ Plugin update complete!"
}

# load zsh-nvm
load_plugin zsh-nvm zsh-nvm.plugin.zsh

# ============================================================================
# Load fzf-tab (must be before compinit)
# ============================================================================

# fzf-tab must be loaded BEFORE compinit, but we already ran compinit in completion.zsh
# If you want to use fzf-tab, make sure to load it in completion.zsh instead

# ============================================================================
# zsh-autosuggestions Configuration
# ============================================================================

# Load zsh-autosuggestions
if [[ -d "${PLUGIN_DIR}/zsh-autosuggestions" ]]; then
    source "${PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
    
    # Autosuggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
    
    # Autosuggestion strategy (try history first, then completion)
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    
    # Buffer max size for autosuggestions
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    
    # Use async mode for better performance
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    
    # Key bindings for autosuggestions
    bindkey '^ ' autosuggest-accept  # Ctrl+Space to accept suggestion
    bindkey '^[[Z' autosuggest-accept  # Shift+Tab to accept suggestion (alternative)
fi

# ============================================================================
# zsh-syntax-highlighting Configuration
# ============================================================================

# Load zsh-syntax-highlighting (must be loaded last)
if [[ -d "${PLUGIN_DIR}/zsh-syntax-highlighting" ]]; then
    source "${PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    
    # Customize highlighting colors
    typeset -A ZSH_HIGHLIGHT_STYLES
    
    # Commands and builtins
    ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[function]='fg=cyan,bold'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
    
    # Paths
    ZSH_HIGHLIGHT_STYLES[path]='fg=blue,underline'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=blue,underline'
    
    # Errors
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow,bold'
    
    # Strings and quotes
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=yellow'
    
    # Options and arguments
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta'
    
    # Comments
    ZSH_HIGHLIGHT_STYLES[comment]='fg=240'
    
    # Brackets and braces
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
    
    # Cursor
    ZSH_HIGHLIGHT_STYLES[cursor]='standout'
fi

# ============================================================================
# Additional Plugins (Optional)
# ============================================================================

# You can add more plugins here by following the same pattern:
# 1. Clone the plugin to ${PLUGIN_DIR}/plugin-name
# 2. Source the main plugin file
# 3. Configure plugin-specific options

# Example: Loading zsh-completions
# if [[ -d "${PLUGIN_DIR}/zsh-completions" ]]; then
#     fpath+="${PLUGIN_DIR}/zsh-completions/src"
# fi

# ============================================================================
# Helpful Aliases for Plugin Management
# ============================================================================

alias plugin-install='install_plugins'
alias plugin-update='update_plugins'
alias plugin-list='ls -1 ${PLUGIN_DIR}'
alias load-plugin='load_plugin'
