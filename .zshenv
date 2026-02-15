# ============================================================================
# ZSH Environment Bootstrap
# ============================================================================
# Symlinked to ~/.zshenv — sourced before .zshrc for all shells (interactive
# and non-interactive). Sets ZDOTDIR so zsh finds .zshrc in the right place.
# ============================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
