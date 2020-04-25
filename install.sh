ls /sys/firmware/efi/efivars
timedatectl set-ntp true
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
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
mkfs.vfat /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux linux-firmware mc base-devel intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Minsk /etc/localtime
hwclock --systohc
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' ./locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch" > /etc/hostname
echo "
127.0.0.1	localhost
::1		localhost
127.0.1.1	arch.localdomain	arch" >> /etc/hosts
bootctl --path=/boot install
echo "title Arch Linux
linux /vmlinuz-linux
initrd  /intel-ucode.img
initrd /initramfs-linux.img 
options root=PARTUUID=XXXX-XXXX-XXXX rw > /boot/loader/entries/arch.conf
echo "root:temppass" | chpasswd
EOF


