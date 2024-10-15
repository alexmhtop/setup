#!/bin/bash/



git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir -p ~/.config/starship/
curl -fsSL https://raw.githubusercontent.com/alexmhtop/setup/refs/heads/main/dotfiles/.zshrc -o ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/alexmhtop/setup/refs/heads/main/dotfiles/.p10k.zsh -o ~/.p10k.zsh
curl -fsSL https://raw.githubusercontent.com/alexmhtop/setup/refs/heads/main/dotfiles/.tmux.conf -o ~/.tmux.conf
curl -fsSL https://raw.githubusercontent.com/alexmhtop/setup/refs/heads/main/dotfiles/starship.toml -o ~/.config/starship/starship.toml

echo "export XDG_DATA_DIRS=/home/linuxbrew/.linuxbrew/share:$XDG_DATA_DIRS" >> ~/.profile
echo "export PATH=/home/linuxbrew/.linuxbrew/sbin:$PATH" >> ~/.profile
echo "export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH" >> ~/.profile

#homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
source .profile

#essentials
sudo apt install -y build-essential
brew install bat bat-extras eza fd gcc rg git-delta k9s kubecolor kubectx neovim zoxide zsh lazygit fzf starship

#tmux
# start a server but don't attach to it
tmux start-server
# create a new session but don't attach to it either
tmux new-session -d
# install the plugins
sleep 1
~/.tmux/plugins/tpm/scripts/install_plugins.sh
# killing the server is not required, I guess
tmux kill-server

#lazy vim
brew install nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git


#lazy vim dependency
brew install pnpm tree-sitter cpanm ruby pipx teller
python3 -m pip install neovim --break-system-packages
brew install node rust
source ~/.zshrc
pnpm -g install neovim
cpanm Neovim::EXT



