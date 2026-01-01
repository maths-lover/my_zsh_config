#!/usr/bin/env zsh
# ============================================================================
# Aliases Configuration
# ============================================================================

# ============================================================================
# General Aliases
# ============================================================================

# ls aliases (use eza/exa if available, otherwise standard ls with colors)
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first --icons always'
    alias ll='eza -lh --group-directories-first --icons always'
    alias la='eza -lha --group-directories-first --icons always'
    alias lt='eza --tree --level=2 --icons always'
    alias l='eza -1 --group-directories-first'
elif command -v exa &>/dev/null; then
    alias ls='exa --group-directories-first'
    alias ll='exa -lh --group-directories-first --icons always'
    alias la='exa -lha --group-directories-first --icons always'
    alias lt='exa --tree --level=2 --icons always'
    alias l='exa -1 --group-directories-first'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lha'
    alias l='ls -1'
fi

# Use bat instead of cat if available
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'  # cat with pager
elif command -v batcat &>/dev/null; then
    alias cat='batcat --paging=never'
    alias catp='batcat'
fi

# Directory navigation
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'  # Go back to previous directory

# Zoxide aliases (if zoxide is installed)
if command -v zoxide &>/dev/null; then
    # z is the main command (aliased by zoxide init)
    # zi for interactive selection with fzf
    alias zz='z -'              # Go to previous directory
    alias zh='z ~'              # Go to home
    alias zc='fz'               # Interactive cd with fzf
    alias zq='zoxide query'     # Query database
    alias zr='zoxide remove'    # Remove directory from database
fi

# Directory listing
alias lsd='ls -d */'  # List only directories
alias lsf='ls -p | grep -v /'  # List only files

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Create parent directories as needed
alias mkdir='mkdir -p'

# Disk usage
alias df='df -h'
alias du='du -h'
alias dud='du -d 1 -h'
alias duf='du -sh *'

# Grep with color
alias grep='grep --color=auto'
# fgrep and egrep are deprecated, but kept for compatibility
# Note: Our custom search function is called 'fzgrep' to avoid conflicts
alias egrep='egrep --color=auto'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias htop='htop --sort-key=PERCENT_CPU'

# Network
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='ip addr show | grep inet | grep -v inet6 | grep -v 127.0.0.1'

# Date and time
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias nowdate='date +"%Y-%m-%d"'
alias nowtime='date +"%H:%M:%S"'

# Quick edits
alias zshrc='${EDITOR:-vim} ${ZDOTDIR:-~/.config/zsh}/.zshrc'
alias zshreload='source ${ZDOTDIR:-~/.config/zsh}/.zshrc'
alias aliases='${EDITOR:-vim} ${ZDOTDIR:-~/.config/zsh}/aliases.zsh'

# ============================================================================
# Git Aliases
# ============================================================================

# Basic commands
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'

# Branch operations
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'

# Commit operations
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gcn!='git commit --verbose --amend --no-edit'
alias gcm='git commit --message'
alias gca='git commit --verbose --all'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --amend --no-edit'

# Checkout operations
alias gsw='git switch'
alias gswc='git switch -c'
alias gswm='git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@")'
alias gswd='git checkout develop'

# Clone
alias gcl='git clone --recurse-submodules'

# Diff operations
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'

# Fetch operations
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

# Log operations
alias gl='git log --oneline --decorate --graph'
alias gla='git log --oneline --decorate --graph --all'
alias glg='git log --graph --pretty=format:"%C(yellow)%h%C(reset) - %C(green)(%cr)%C(reset) %s %C(blue)<%an>%C(reset)%C(auto)%d%C(reset)"'
alias gll='git log --pretty=format:"%C(yellow)%h%C(red)%d%C(reset) - %C(cyan)%an%C(reset): %s %C(green)(%cr)%C(reset)"'

# Pull operations
alias gl='git pull'
alias gpl='git pull'
alias gpr='git pull --rebase'
alias gup='git pull --rebase --autostash'

# Push operations
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpc='git push --set-upstream origin $(git symbolic-ref --short HEAD)'

# Rebase operations
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'

# Reset operations
alias grh='git reset'
alias grhh='git reset --hard'
alias grhs='git reset --soft'

# Restore operations
alias grs='git restore'
alias grss='git restore --staged'

# Remote operations
alias gr='git remote'
alias gra='git remote add'
alias grv='git remote --verbose'

# Stash operations
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'

# Status operations
alias gs='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'

# Switch operations (Git 2.23+)
alias gsw='git switch'
alias gswc='git switch --create'
alias gswm='git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@")'

# Show operations
alias gsh='git show'
alias gshs='git show --stat'

# Submodule operations
alias gsu='git submodule update --init --recursive'

# Tag operations
alias gt='git tag'
alias gts='git tag --sort=-version:refname'

# Worktree operations
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'

# Quick shortcuts
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gwip='git add -A; git commit -m "WIP" --no-verify'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

# ============================================================================
# Docker Aliases (if Docker is installed)
# ============================================================================

if command -v docker &>/dev/null; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlog='docker logs -f'
    alias dprune='docker system prune -a --volumes'
fi

# ============================================================================
# Kubernetes Aliases (if kubectl is installed)
# ============================================================================

if command -v kubectl &>/dev/null; then
    alias k='kubectl'
    alias kg='kubectl get'
    alias kd='kubectl describe'
    alias kdel='kubectl delete'
    alias kl='kubectl logs'
    alias kex='kubectl exec -it'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgn='kubectl get nodes'
fi

# ============================================================================
# Python Aliases
# ============================================================================

alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate || source env/bin/activate || source .venv/bin/activate'

# ============================================================================
# Misc Aliases
# ============================================================================

# Quick HTTP server
alias serve='python3 -m http.server'

# JSON pretty print
alias json='python3 -m json.tool'

# Make watch work with aliases
alias watch='watch '

# Clipboard (if available)
if command -v xclip &>/dev/null; then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi
