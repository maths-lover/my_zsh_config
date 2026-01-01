# ============================================================================
# Main ZSH Configuration
# Location: ~/.config/zsh/.zshrc (symlinked from ~/.zshrc)
# ============================================================================

# Set XDG_CONFIG_HOME if not set
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# ZSH configuration directory
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# ============================================================================
# Performance Optimization
# ============================================================================

# Enable profiling (uncomment to debug slow startup)
#zmodload zsh/zprof

# Disable automatic updates check
DISABLE_AUTO_UPDATE="true"

# Skip global compinit (we'll do it ourselves)
skip_global_compinit=1

# ============================================================================
# History Configuration
# ============================================================================

HISTFILE="${ZDOTDIR}/.zsh_history"
HISTSIZE=5000000
SAVEHIST=5000000

# History options
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
setopt SHARE_HISTORY             # Share history between sessions

# ============================================================================
# ZSH Options
# ============================================================================

# Directory options
setopt AUTO_CD                   # cd by typing directory name if it's not a command
setopt AUTO_PUSHD                # Make cd push old directory onto directory stack
setopt PUSHD_IGNORE_DUPS         # Don't push multiple copies of same directory
setopt PUSHD_SILENT              # Don't print directory stack after pushd/popd

# Completion options
setopt ALWAYS_TO_END             # Move cursor to end if word completed
setopt AUTO_MENU                 # Show completion menu on tab press
setopt COMPLETE_IN_WORD          # Complete from both ends of word
setopt LIST_PACKED               # Make completion list smaller
setopt AUTO_PARAM_SLASH          # Add trailing slash for directories

# Correction
setopt CORRECT                   # Spelling correction for commands
setopt CORRECT_ALL               # Spelling correction for arguments

# Misc
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shells
setopt MULTIOS                   # Implicit tees or cats when multiple redirections
setopt PROMPT_SUBST              # Enable parameter expansion in prompts

# Disable beep
unsetopt BEEP

# ============================================================================
# Load Modular Configurations
# ============================================================================

# Source files if they exist
function source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

# Load environment variables first
source_if_exists "${ZDOTDIR}/environment.zsh"

# Load SSH agent
source_if_exists "${ZDOTDIR}/ssh-agent.zsh"

# Load aliases
source_if_exists "${ZDOTDIR}/aliases.zsh"

# Load functions
source_if_exists "${ZDOTDIR}/functions.zsh"

# Load completion system
source_if_exists "${ZDOTDIR}/completion.zsh"

# Load fzf integrations
source_if_exists "${ZDOTDIR}/fzf.zsh"

# Load plugins (must be near the end)
source_if_exists "${ZDOTDIR}/plugins.zsh"

# Initialize starship prompt (must be at the end)
eval "$(starship init zsh)"

# ============================================================================
# Performance Profiling (uncomment to see startup times)
# ============================================================================

#zprof
