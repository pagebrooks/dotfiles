#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt install -y \
	uuid \
	jq \
	build-essential \
	curl

# Install 1Password
which 1password
if [[ $? != 0 ]]; then
	ONE_PASS=1password-latest.deb
	curl https://downloads.1password.com/linux/debian/amd64/stable/$ONE_PASS --output /tmp/$ONE_PASS
	sudo apt install -y /tmp/$ONE_PASS
	rm /tmp/$ONE_PASS
else
	echo "1Password already installed"
fi

# Install Homebrew
which brew
if [[ $? != 0 ]]; then
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	brew update
fi

brew install \
	bat \
	jandedobbeleer/oh-my-posh/oh-my-posh \
	neofetch \
	neovim \
	htop \
	ripgrep \
	z \
	zellij \
	lolcat \
	cowsay

echo 'Installing nerd-fonts'
git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1
pushd nerd-fonts
./install.sh
popd
rm -rf -- nerd-fonts