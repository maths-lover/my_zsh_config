#!/usr/bin/env zsh
# ============================================================================
# FZF (Fuzzy Finder) Configuration
# ============================================================================

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    return
fi

# ============================================================================
# FZF Default Options
# ============================================================================

# Set default options for fzf
export FZF_DEFAULT_OPTS="
    --height=50%
    --layout=reverse
    --border=rounded
    --inline-info
    --preview-window=right:50%:wrap
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-half-page-up'
    --bind='ctrl-d:preview-half-page-down'
    --bind='ctrl-a:select-all'
    --bind='ctrl-y:execute-silent(echo {+} | pbcopy)'
    --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
    --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
    --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
    --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
"

# ============================================================================
# FZF Command Defaults
# ============================================================================

# Use fd for file listing if available, otherwise fallback to find
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ============================================================================
# FZF Preview Commands
# ============================================================================

# File preview with bat/cat
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="
        --preview 'bat --color=always --style=numbers --line-range=:500 {}'
        --preview-window='right:60%:wrap'
    "
elif command -v batcat &>/dev/null; then
    export FZF_CTRL_T_OPTS="
        --preview 'batcat --color=always --style=numbers --line-range=:500 {}'
        --preview-window='right:60%:wrap'
    "
else
    export FZF_CTRL_T_OPTS="
        --preview 'head -n 500 {}'
        --preview-window='right:60%:wrap'
    "
fi

# Directory preview with tree/ls
if command -v tree &>/dev/null; then
    export FZF_ALT_C_OPTS="
        --preview 'tree -C -L 2 {} | head -200'
        --preview-window='right:60%:wrap'
    "
else
    export FZF_ALT_C_OPTS="
        --preview 'ls -lh {}'
        --preview-window='right:60%:wrap'
    "
fi

# ============================================================================
# Source FZF Key Bindings and Completion
# ============================================================================

# Try to source fzf from common locations
FZF_LOCATIONS=(
    "/usr/share/fzf/key-bindings.zsh"
    "/usr/share/fzf/completion.zsh"
    "/usr/share/doc/fzf/examples/key-bindings.zsh"
    "/usr/share/doc/fzf/examples/completion.zsh"
    "${HOME}/.fzf/shell/key-bindings.zsh"
    "${HOME}/.fzf/shell/completion.zsh"
    "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
    "/opt/homebrew/opt/fzf/shell/completion.zsh"
)

for fzf_file in "${FZF_LOCATIONS[@]}"; do
    [[ -f "$fzf_file" ]] && source "$fzf_file"
done

# ============================================================================
# Custom FZF Functions
# ============================================================================

# Interactive cd to any directory
fcd() {
    local dir
    if command -v fd &>/dev/null; then
        dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'tree -C -L 2 {} 2>/dev/null || ls -lh {}')
    else
        dir=$(find . -type d 2>/dev/null | fzf --preview 'tree -C -L 2 {} 2>/dev/null || ls -lh {}')
    fi
    
    if [[ -n "$dir" ]]; then
        # Use zoxide if available to track directory changes
        if command -v zoxide &>/dev/null; then
            z "$dir"
        else
            cd "$dir"
        fi
    fi
}

# Interactive cd using zoxide database (if available)
fz() {
    if ! command -v zoxide &>/dev/null; then
        echo "Error: zoxide is not installed"
        return 1
    fi
    
    local dir
    dir=$(zoxide query -l | fzf --preview 'ls -lh {}' --preview-window='right:60%:wrap')
    [[ -n "$dir" ]] && z "$dir"
}

# Interactive file opening with default editor
fopen() {
    local file
    if command -v fd &>/dev/null; then
        file=$(fd --type f --hidden --follow --exclude .git | fzf --preview 'bat --color=always --style=numbers {}' --preview-window='right:70%:wrap')
    else
        file=$(find . -type f 2>/dev/null | fzf --preview 'bat --color=always --style=numbers {}' --preview-window='right:70%:wrap')
    fi
    [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# Search in file contents and open in editor
# Using fzf + ripgrep for interactive search
fzgrep() {
    if ! command -v rg &>/dev/null; then
        echo "Error: ripgrep (rg) is required for this function"
        echo "Install with: sudo apt install ripgrep  # or: cargo install ripgrep"
        return 1
    fi

    if [[ $# -eq 0 ]]; then
        echo "Usage: fzgrep <pattern> [path]"
        echo "Example: fzgrep 'TODO' ."
        return 1
    fi

    local pattern="$1"
    local search_path="${2:-.}"
    
    # First check if ripgrep finds anything
    if ! rg --line-number --no-heading --color=always --smart-case "$pattern" "$search_path" &>/dev/null; then
        echo "No matches found for: $pattern"
        return 1
    fi
    
    local result
    result=$(
        rg --line-number \
           --no-heading \
           --color=always \
           --smart-case \
           "$pattern" \
           "$search_path" 2>/dev/null |
        fzf --ansi \
            --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null || cat {1} 2>/dev/null' \
            --preview-window='right:60%:+{2}/2'
    )
    
    # Exit if user cancelled (pressed ESC)
    if [[ -z "$result" ]]; then
        return 0
    fi
    
    local file=$(echo "$result" | awk -F: '{print $1}')
    local line=$(echo "$result" | awk -F: '{print $2}')
    
    if [[ -n "$file" && -n "$line" ]]; then
        ${EDITOR:-vim} "$file" +$line
    fi
}

# Interactive process kill
fkill() {
    local pid
    pid=$(ps aux | sed 1d | fzf --multi | awk '{print $2}')
    
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# Interactive git branch checkout
fgb() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)') &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Interactive git log browser
fglog() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show --color=always %' \
        --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
FZF-EOF"
}

# Interactive git stash browser
fgst() {
    local stash
    stash=$(git stash list | fzf --preview 'echo {} | cut -d: -f1 | xargs git stash show -p --color=always' | cut -d: -f1)
    [[ -n "$stash" ]] && git stash show -p "$stash"
}

# Interactive docker container selection
fdocker() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf --query="$1" | awk '{print $1}')
    [[ -n "$cid" ]] && docker exec -it "$cid" /bin/bash
}

# Interactive docker image removal
fdocker-rmi() {
    docker images | sed 1d | fzf --multi --query="$1" | awk '{print $3}' | xargs -r docker rmi
}

# Search command history
fhistory() {
    local cmd
    cmd=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | fzf --tac --no-sort --query="$1")
    [[ -n "$cmd" ]] && print -z "$cmd"
}

# Interactive environment variable viewer
fenv() {
    local var
    var=$(env | fzf --preview 'echo {}')
    [[ -n "$var" ]] && echo "$var"
}

# Find and cd to git repository root
froot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    [[ -n "$root" ]] && cd "$root"
}

# Interactive man page browser
fman() {
    man -k . | fzf --preview 'echo {} | cut -d " " -f1 | xargs man' | cut -d " " -f1 | xargs -r man
}

# ============================================================================
# FZF-Tab Integration (if installed)
# ============================================================================

# This provides fzf-like completion for tab completion
# Install: git clone https://github.com/Aloxaf/fzf-tab ${ZDOTDIR}/plugins/fzf-tab
if [[ -d "${ZDOTDIR}/plugins/fzf-tab" ]]; then
    source "${ZDOTDIR}/plugins/fzf-tab/fzf-tab.plugin.zsh"
    
    # Configure fzf-tab
    zstyle ':fzf-tab:*' fzf-flags --height=50% --border=rounded
    zstyle ':fzf-tab:*' fzf-preview-window right:50%:wrap
    
    # Preview for files
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
    
    # Preview for directories
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'
fi

# ============================================================================
# Key Bindings
# ============================================================================

# Ctrl+R for history search using fzf
bindkey '^R' fzf-history-widget

# Ctrl+T for file search
bindkey '^T' fzf-file-widget

# Alt+C for directory search
bindkey '\ec' fzf-cd-widget

# Custom: Ctrl+G for grep search (if fzgrep function is defined)
bindkey -s '^G' 'fzgrep '

# Custom: Alt+F for finding files - inserts 'fopen' and enters
bindkey -s '\ef' 'fopen\n'
