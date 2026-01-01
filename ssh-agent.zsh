#!/usr/bin/env zsh
# ============================================================================
# SSH Agent Configuration
# ============================================================================

# SSH agent environment file
SSH_ENV="${HOME}/.ssh/agent.env"

# Function to start SSH agent
start_ssh_agent() {
    echo "Starting new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    source "${SSH_ENV}" > /dev/null
    
    # Automatically add default SSH keys if they exist
    local default_keys=(
        "${HOME}/.ssh/id_rsa"
        "${HOME}/.ssh/id_ed25519"
        "${HOME}/.ssh/id_ecdsa"
    )
    
    for key in "${default_keys[@]}"; do
        if [[ -f "${key}" ]]; then
            ssh-add "${key}" 2>/dev/null
        fi
    done
}

# Function to check if SSH agent is running
is_ssh_agent_running() {
    [[ -n "${SSH_AGENT_PID}" ]] && ps -p "${SSH_AGENT_PID}" > /dev/null 2>&1
}

# ============================================================================
# Main SSH Agent Logic
# ============================================================================

# Check if SSH agent environment file exists and source it
if [[ -f "${SSH_ENV}" ]]; then
    source "${SSH_ENV}" > /dev/null
fi

# If agent is not running or the PID is invalid, start a new one
if ! is_ssh_agent_running; then
    start_ssh_agent
fi

# ============================================================================
# Helper Functions
# ============================================================================

# List loaded SSH keys
ssh-keys() {
    ssh-add -l
}

# Add SSH key
ssh-add-key() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ssh-add-key <path-to-key>"
        echo "Example: ssh-add-key ~/.ssh/id_rsa"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "Error: Key file not found: $1"
        return 1
    fi
    
    ssh-add "$1"
}

# Remove all SSH keys from agent
ssh-clear() {
    ssh-add -D
    echo "All SSH keys removed from agent"
}

# Restart SSH agent
ssh-restart() {
    # Kill existing agent if running
    if is_ssh_agent_running; then
        echo "Stopping existing SSH agent (PID: ${SSH_AGENT_PID})..."
        kill "${SSH_AGENT_PID}" 2>/dev/null
    fi
    
    # Remove old environment file
    [[ -f "${SSH_ENV}" ]] && rm "${SSH_ENV}"
    
    # Start new agent
    start_ssh_agent
}

# ============================================================================
# SSH Agent Forwarding (for remote sessions)
# ============================================================================

# Enable SSH agent forwarding for remote sessions
# This is useful when you SSH into a remote machine and want to use your local SSH keys
# Add this to your ~/.ssh/config:
#   Host *
#       ForwardAgent yes

# ============================================================================
# Optional: Keychain Integration
# ============================================================================

# If you prefer using keychain instead of manual SSH agent management,
# uncomment the following section and install keychain:
#   - Ubuntu/Debian: sudo apt install keychain
#   - Fedora/RHEL:   sudo dnf install keychain
#   - macOS:         brew install keychain

# if command -v keychain &>/dev/null; then
#     eval $(keychain --eval --quiet id_rsa id_ed25519)
# fi
