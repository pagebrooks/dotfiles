#!/bin/bash

# Comment out the CDROM sources for apt 
sudo sed -i.bak -r '/deb cdrom:/s/^/#/' /etc/apt/sources.list 

# Prepare clevis 
clevis=$(sudo cryptsetup luksDump /dev/nvme0n1p3 | grep clevis -c)
if [[ $clevis -gt 0 ]]; then
	exit
fi

sudo apt install -y curl clevis clevis-luks clevis-initramfs clevis-udisks2 clevis-systemd clevis-tpm2

echo "Binding clevis to luks-encrypted volume"
sudo clevis luks bind -d /dev/nvme0n1p3 tpm2 '{"pcr_bank":"sha256","pcr_ids":"1,7"}'
sudo update-initramfs -u

# References:
# https://kowalski7cc.xyz/blog/luks2-tpm2-clevis-fedora31/
# https://wiki.archlinux.org/title/Clevis
