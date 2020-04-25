ls /sys/firmware/efi/efivars
echo -n Enter the name of the drive to install (for examples, sda):
read drive_name
echo -n Enter computer name:
read computer_name
echo -n Enter root password:
read -s root_password
echo -n Confirm root password:
read -s root_password_confirm
if [ $root_password -ne $root_password_confirm ] ; then echo "passwords do not match run the script again" && exit 1 ; fi
timedatectl set-ntp true
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/$drive_name
g # create gtp partition table
n # new partition
1 # partition number 1
  # default - start at beginning of disk
+550M # 550 MB efi partition
t # change parttion type
1 # efi type
n # new partition
2 # partition number 2
  # default - start at beginning of disk
+1024M # 1024 MB swap parttion
t # change parttion type
2 # partition number 2
19 # swap type
n # new partition
3 # partition number 3
  # default, start immediately after preceding partition
  # default, extend partition to end of disk
w # write the partition table
q # and we're done
EOF
mkfs.vfat /dev/$drive_name\1
mkswap /dev/$drive_name\2
swapon /dev/$drive_name\2
mkfs.ext4 /dev/$drive_name\3
mount /dev/$drive_name\3 /mnt
mkdir /mnt/boot
mount /dev/$drive_name\1 /mnt/boot
pacstrap /mnt base linux linux-firmware mc base-devel networkmanager intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Minsk /etc/localtime
hwclock --systohc
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' ./locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$computer_name" > /etc/hostname
echo "
127.0.0.1	localhost
::1		localhost
127.0.1.1	$computer_name.localdomain	$computer_name" >> /etc/hosts
bootctl --path=/boot install
echo "title Arch Linux
linux /vmlinuz-linux
initrd  /intel-ucode.img
initrd /initramfs-linux.img" > /boot/loader/entries/arch.conf
echo "options root=UUID=$(blkid | grep /dev/$drive_name\3 | awk -F '"' '{print $2}') rw" >> /boot/loader/entries/arch.conf
echo "root:$root_password" | chpasswd
systemctl enable NetworkManager
EOF