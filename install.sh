ls /sys/firmware/efi/efivars
timedatectl set-ntp true
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
g # create gtp partition table
n # new partition
1 # partition number 1
  # default - start at beginning of disk
+550M # 550 MB boot parttion
t # change parttion type
4 # boot type
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
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
mkdir /mnt/boot/efi
pacstrap /mnt base linux linux-firmware mc base-devel grub networkmanager os-prober dialog wpa_supplicant efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Minsk /etc/localtime
hwclock --systohc
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
echo "arch" > /etc/hostname
echo "
127.0.0.1	localhost
::1		localhost
127.0.1.1	arch.localdomain	arch" >> /etc/hosts
passwd
EOF


