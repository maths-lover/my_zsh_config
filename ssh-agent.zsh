#!/usr/bin/env zsh
# ============================================================================
# SSH Agent Configuration (macOS)
# ============================================================================
# On macOS, launchd manages ssh-agent automatically.
# Combined with UseKeychain + AddKeysToAgent in ~/.ssh/config,
# passphrases are stored in the system Keychain and keys are
# added to the agent on first use — no manual ssh-add needed.
# ============================================================================

# Add keys to the macOS Keychain agent on first shell session.
# --apple-use-keychain stores the passphrase in the Keychain so
# subsequent uses won't prompt for a password.
if [[ "$(uname)" == "Darwin" ]]; then
    # Only add if no identities are loaded yet
    if ! ssh-add -l &>/dev/null; then
        ssh-add --apple-load-keychain 2>/dev/null

        # If nothing in keychain yet, add default keys with keychain storage
        if ! ssh-add -l &>/dev/null; then
            local default_keys=(
                "${HOME}/.ssh/id_ed25519"
                "${HOME}/.ssh/id_rsa"
                "${HOME}/.ssh/id_ecdsa"
            )
            for key in "${default_keys[@]}"; do
                if [[ -f "${key}" ]]; then
                    ssh-add --apple-use-keychain "${key}" 2>/dev/null
                fi
            done
        fi
    fi
fi

# ============================================================================
# Helper Functions
# ============================================================================

# List loaded SSH keys
ssh-keys() {
    ssh-add -l
}

# Add SSH key (with Keychain storage on macOS)
ssh-add-key() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ssh-add-key <path-to-key>"
        echo "Example: ssh-add-key ~/.ssh/id_ed25519"
        return 1
    fi

    if [[ ! -f "$1" ]]; then
        echo "Error: Key file not found: $1"
        return 1
    fi

    if [[ "$(uname)" == "Darwin" ]]; then
        ssh-add --apple-use-keychain "$1"
    else
        ssh-add "$1"
    fi
}

# Remove all SSH keys from agent
ssh-clear() {
    ssh-add -D
    echo "All SSH keys removed from agent"
}
