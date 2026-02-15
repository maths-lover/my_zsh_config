#!/bin/zsh

# First check if homebrew is installed or not
# if not, please do install it and run again

if ! command -v brew >/dev/null 2>&1; then
  echo "Please install Homebrew and try this script again" >&2
  exit 1
fi

# Check if all the tools are installed or not with brew
# tools are defined as "brew_package:binary_name"
TOOLS_LIST=(
  "bat:bat"
  "eza:eza"
  "fd:fd"
  "fzf:fzf"
  "ripgrep:rg"
  "zoxide:zoxide"
  "starship:starship"
  "neovim:nvim"
  "fastfetch:fastfetch"
  "git:git"
)

missing_packages=()

for entry in "${TOOLS_LIST[@]}"; do
  brew_pkg="${entry%%:*}"   # left side of colon
  binary="${entry##*:}"     # right side of colon

  if ! command -v "$binary" >/dev/null 2>&1; then
    echo "Missing: $binary (brew package: $brew_pkg)"
    missing_packages+=("$brew_pkg")
  else
    echo "Installed: $binary"
  fi
done

if [ "${#missing_packages[@]}" -ne 0 ]; then
  echo
  echo "You can install missing tools with:"
  echo "  brew install ${missing_packages[*]}"
  exit 1
fi

echo "All tools are installed."
