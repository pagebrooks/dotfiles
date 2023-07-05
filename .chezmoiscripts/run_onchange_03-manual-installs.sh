#!/bin/bash

set -x

# Install 1Password
which 1password
if [[ $? != 0 ]]; then
	ONE_PASS=1password-latest.deb
	curl -L -o /tmp/$ONE_PASS https://downloads.1password.com/linux/debian/amd64/stable/$ONE_PASS
	sudo apt install -y /tmp/$ONE_PASS
	rm /tmp/$ONE_PASS
else
	echo "1Password already installed"
fi

which obsidian
if [[ $? != 0 ]]; then
	OBSIDIAN_VERSION="1.3.5"
	curl -L -o /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
	sudo apt install -y /tmp/obsidian.deb
	rm /tmp/obsidian.deb
else
	echo "Obsidian already installed"
fi
