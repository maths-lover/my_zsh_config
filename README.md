# My ZSH Config

Cross-platform ZSH configuration with a bootstrap script that works on macOS (Apple Silicon / Intel) and Linux (Debian/Ubuntu, Fedora/RHEL, Arch).

## Setup

```bash
git clone git@github.com:maths-lover/zsh_config.git ~/.config/zsh && bash ~/.config/zsh/setup_zsh.sh
```

The setup script will:

- Install zsh and set it as the default shell
- Install CLI tools: bat, eza, fd, fzf, ripgrep, zoxide, starship, neovim, fastfetch, git, tree
- Install pyenv and build dependencies
- Install zsh plugins (autosuggestions, syntax-highlighting, fzf-tab, zsh-nvm)
- Create symlinks for `.zshenv`, `.zshrc`, `starship.toml`, and `ripgreprc`

Once done, open a new terminal or run `exec zsh -l`.
