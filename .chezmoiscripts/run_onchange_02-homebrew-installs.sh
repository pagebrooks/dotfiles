#!/bin/bash

set -x

# Install Homebrew
which brew
if [[ $? != 0 ]]; then
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.profile
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
	brew update
fi


# Nerdfonts isn't working right now
#if [ ! -d "~/.local/share/fonts/NerdFonts" ]; then
#	echo 'Installing nerd-fonts'
#	git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1
#	pushd nerd-fonts
#	./install.sh
#	popd
#	rm -rf -- nerd-fonts
#else
#	echo 'nerd-fonts already installed'
#fi

brew install \
	bat \
	cowsay \
	gh \
	lolcat \
	neofetch \
	neovim \
	htop \
	ripgrep \
	tldr \
	z \
	zellij

	# commented out until nerdfonts is fixed
	#jandedobbeleer/oh-my-posh/oh-my-posh \
