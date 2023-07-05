#!/bin/bash

set -x

sudo apt update
sudo apt upgrade
sudo apt install -y \
	alsa-utils \
	awesome \
	bc \
	build-essential \
	curl \
	firefox-esr \
	git \
	jq \
	lightdm \
 	locate \
	nala \
	pulseaudio \
	uuid \
	xclip \
	xbindkeys

sudo updatedb
