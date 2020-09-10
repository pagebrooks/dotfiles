
# https://help.ubuntu.com/community/WifiDocs/Driver/bcm43xx
# Install Broadcom STA driver

sudo apt-get --reinstall install bcmwl-kernel-source

sudo modprobe -r b43 ssb wl brcmfmac brcmsmac bcma
sudo modprobe wl

sudo apt install ifconfig wireless-tools wpasupplicant -y

# https://wiki.archlinux.org/index.php/Wpa_supplicant#At_boot_(systemd)

