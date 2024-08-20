#Use this to insert the partuuid on the boot loader
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p3) rw" >> /boot/loader/entries/*.conf
