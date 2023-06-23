#!/bin/sh

device=$(echo $1 | cut -d: -f1)
filepath=$(echo $1 | cut -d: -f2)

# Ask for password if device doesn't exist
sleep 2
if [ ! -b $device ]; then
    /lib/cryptsetup/askpass "Device '$device' not found, enter passphrase: "
    exit
fi

mkdir -p /tmp/auto-unlocker
mount $device /tmp/auto-unlocker

# Again ask for password if device exist but file doesn't exist
if [ ! -e /tmp/auto-unlocker$filepath ]; then
    /lib/cryptsetup/askpass "File '$filepath' not found, enter passphrase: "
else
    cat /tmp/auto-unlocker$filepath
fi

umount /tmp/auto-unlocker

# References:
#https://askubuntu.com/questions/59487/how-to-configure-lvm-luks-to-autodecrypt-partition
