#!/bin/bash

set -e

# Comment out the CDROM sources for apt 
sudo sed -i.bak -r '/deb cdrom:/s/^/#/' /etc/apt/sources.list

# Prerequisites for TPM integration with full disk encryption
sudo apt install -y \
	curl \
	clevis \
	clevis-luks \
	clevis-initramfs \
	clevis-udisks2 \
	clevis-systemd \
	clevis-tpm2

# References:
# https://kowalski7cc.xyz/blog/luks2-tpm2-clevis-fedora31/
# https://wiki.archlinux.org/title/Clevis
