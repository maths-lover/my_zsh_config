#!/usr/bin/env zsh
# ============================================================================
# ZSH Completion System Configuration
# ============================================================================

# ============================================================================
# Completion System Initialization
# ============================================================================

# Set up completion directory
fpath=("${ZDOTDIR}/completions" $fpath)

# Initialize completion system (only once)
autoload -Uz compinit

# Speed up compinit by checking once per day
# This significantly improves shell startup time
setopt EXTENDEDGLOB
for dump in ${ZDOTDIR}/.zcompdump(N.mh+24); do
    compinit
done
compinit -C
unsetopt EXTENDEDGLOB

# ============================================================================
# Completion Styles
# ============================================================================

# Use menu selection
zstyle ':completion:*' menu select

# Case-insensitive (all), partial-word, and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Group completions by type
zstyle ':completion:*' group-name ''

# Use colors in completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# More detailed completion descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# Cache completions for better performance
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZDOTDIR}/.zcompcache"

# Fuzzy matching of completions for typos
zstyle ':completion:*' completer _expand _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Better process completion
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Man page completion
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# SSH/SCP/RSYNC completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Allow completion in the middle of a word
zstyle ':completion:*' completer _complete _ignored _approximate

# Completion for common commands
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

# Don't complete already-present arguments
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Separate man page sections
zstyle ':completion:*:manuals' separate-sections true

# Ignore compiled files
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'

# ============================================================================
# Key Bindings for Completion
# ============================================================================

# Use shift-tab to go backwards in completion menu
bindkey '^[[Z' reverse-menu-complete

# Accept completion with right arrow
bindkey '^[[C' forward-char

# ============================================================================
# Additional Completion Sources
# ============================================================================

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# ============================================================================
# Tool-specific Completions
# ============================================================================

# kubectl completion (if kubectl is installed)
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
fi

# docker completion (if docker is installed)
if command -v docker &>/dev/null && [[ ! -f "${ZDOTDIR}/completions/_docker" ]]; then
    mkdir -p "${ZDOTDIR}/completions"
fi

# aws cli completion (if aws is installed)
if command -v aws_completer &>/dev/null; then
    complete -C aws_completer aws
fi

# gh cli completion (if gh is installed)
if command -v gh &>/dev/null; then
    eval "$(gh completion -s zsh)"
fi

# ============================================================================
# Enable Additional Completions
# ============================================================================

# pip completion
if command -v pip3 &>/dev/null; then
    eval "$(pip3 completion --zsh 2>/dev/null)"
fi

# Cargo completion
if command -v rustup &>/dev/null; then
    fpath+=~/.zfunc
fi
