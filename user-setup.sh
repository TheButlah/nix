#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o errtrace  # pass ERR trap down to functions, substitutions, etc
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if [[ "${SHELL}" != *"zsh" ]]; then
	echo "Expected zsh shell."
	return 1
fi

if [[ "${USER}" == "root" ]]; then
	echo "Expected non-root user."
	return 1
fi

if [[ "${USER}" == "ryan" ]]; then
	git config --global user.name "Ryan Butler"
	git config --global user.email "thebutlah@gmail.com"
fi


mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
echo 'eval "$(starship init bash)"' >> ~/.bashrc
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
echo 'set -o vi' >> ~/.zshrc
echo 'set -o vi' >> ~/.bash_profile

ln -sf ${HOME}/P/nix/starship.toml ${HOME}/.config/starship.toml
mkdir -p ~/.config/wezterm
ln -sf ${HOME}/P/nix/wezterm.lua ${HOME}/.config/wezterm/wezterm.lua
mkdir -p ~/.config/alacritty
ln -sf ${HOME}/P/nix/alacritty.toml ${HOME}/.config/alacritty/alacritty.toml

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

pushd ~/P/nix
nix profile install .
popd
