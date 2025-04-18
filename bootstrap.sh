#!/usr/bin/env bash
set -euo pipefail

# Determine OS and script directory
type=$(uname -s)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_REPO="https://raw.githubusercontent.com/alexmhtop/setup/refs/heads/main/dotfiles"

# Install prerequisites and Homebrew/Linuxbrew
install_brew() {
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/usr/local/bin/brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv || /home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

if [[ "$type" == "Darwin" ]]; then
  # macOS
  if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode CLI tools..."
    xcode-select --install
    until xcode-select -p &>/dev/null; do sleep 5; done
  fi
  if ! command -v brew &>/dev/null; then
    install_brew
  fi
elif [[ "$type" == "Linux" ]]; then
  # Ubuntu/Debian
  if command -v apt-get &>/dev/null; then
    echo "Updating apt and installing build essentials..."
    sudo apt-get update
    sudo apt-get install -y build-essential curl file git
  fi
  if ! command -v brew &>/dev/null; then
    echo "Installing Linuxbrew..."
    install_brew
  fi
else
  echo "Unsupported OS: $type"
  exit 1
fi

# Ensure Homebrew is in PATH
if ! command -v brew &>/dev/null; then
  echo "Homebrew/Linuxbrew installation failed."
  exit 1
fi
brew update

# Clone tmux plugin manager (TPM)
if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# Download dotfiles
echo "Fetching dotfiles..."
mkdir -p "${HOME}/.config/starship"
curl -fsSL "${DOTFILES_REPO}/.zshrc"    -o "${HOME}/.zshrc"
curl -fsSL "${DOTFILES_REPO}/.p10k.zsh"  -o "${HOME}/.p10k.zsh"
curl -fsSL "${DOTFILES_REPO}/.tmux.conf" -o "${HOME}/.tmux.conf"
curl -fsSL "${DOTFILES_REPO}/starship.toml" -o "${HOME}/.config/starship/starship.toml"

# Export paths for Homebrew/Linuxbrew
ZPROFILE="${HOME}/.zprofile"
echo "export PATH=\"$(brew --prefix)/bin:$(brew --prefix)/sbin:\$PATH\"" >> "${ZPROFILE}"
echo "export XDG_DATA_DIRS=\"$(brew --prefix)/share:\$XDG_DATA_DIRS\""   >> "${ZPROFILE}"
source "${ZPROFILE}"

# Use Brewfile for cross-platform package install
cd "$SCRIPT_DIR"
brew tap homebrew/bundle
brew bundle --file "$SCRIPT_DIR/Brewfile"

# Install macOS-only casks
if [[ "$type" == "Darwin" ]]; then
  brew install --cask iterm2 docker
fi

# Install tmux plugins non-interactively
if command -v tmux &>/dev/null; then
  tmux start-server
  tmux new-session -d
  sleep 1
  "${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh"
  tmux kill-server
fi

# Setup Neovim (LazyVim starter)
if [[ ! -d "${HOME}/.config/nvim" ]]; then
  git clone https://github.com/LazyVim/starter "${HOME}/.config/nvim"
  rm -rf "${HOME}/.config/nvim/.git"
fi

# Neovim language tooling
cpanm --local-lib="${HOME}/perl5" Neovim::Ext || true
pipx ensurepath
pipx install neovim || true
pnpm install -g neovim || true

echo "✅ Bootstrap complete! Restart your shell or open a new terminal."
