ls /sys/firmware/efi/efivars
timedatectl set-ntp true
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
g # create gtp partition table
n # new partition
1 # partition number 1
  # default - start at beginning of disk
+550M # 550 MB efi parttion
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
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt
mount /dev/sda1 /mnt/efi
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Minsk /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch" > /etc/hostname
echo "
127.0.0.1	localhost
::1		localhost
127.0.1.1	myhostname.localdomain	myhostname" >> /etc/hosts
