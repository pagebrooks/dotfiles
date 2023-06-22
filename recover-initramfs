cryptsetup luksOpen /dev/nvme0n1p3 nvme0n1p3_crypt
vgchange -ay
mkdir /mnt
mount -t ext4 /dev/mapper/thinkpad--vg-root /mnt
mount /dev/nvme0n1p2 /mnt/boot
mount -t proc proc /mnt/proc
mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
chroot /mnt

# Fix /etc/crypttab
# Run update-initramfs -u
# Reboot

