#!/bin/bash

echo "Configuring LUKS automatic unlock with USB drive"
read -p "Please ensure the USB drive is inserted and Press enter to continue..."

echo "Generating random key"
apt install uuid -y
unique_id=$(uuid)
dd if=/dev/urandom bs=1 count=256 > $unique_id.lek
echo "$unique_id.lek has been generated"

echo "Copying random key to USB drive"
cp $unique_id.lek /media/page/key/

echo "Adding unique key with cryptsetup"
cryptsetup luksAddKey /dev/nvme0n1p3 $unique_id.lek

rm $unique_id.lek

echo "Copying auto-unlock script to /bin"
cp auto-unlock /bin

echo "Copying recovery script to /bin"
cp recover-initramfs /bin

echo "Updating /etc/crypttab with keyscript and USB drive/file info"
sed -i "s/none/\/dev\/disk\/by\-label\/key:\/$unique_id.lek/" /etc/crypttab
sed -i "s/discard/keyscript=\/bin\/auto-unlock/" /etc/crypttab

echo "Adding modules to /etc/initramfs-tools/modules file"
echo 'vfat' >> /etc/initramfs-tools/modules
echo 'nls_cp437' >> /etc/initramfs-tools/modules
echo 'nls_ascii' >> /etc/initramfs-tools/modules
echo 'usb_storage' >> /etc/initramfs-tools/modules

echo "Running update-initramfs"
update-initramfs -u
