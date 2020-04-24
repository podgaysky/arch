ls /sys/firmware/efi/efivars
timedatectl set-ntp true
(
echo g
echo 1
echo 
echo +550M
echo t
echo 1
echo n
echo 2
echo 
echo +1024M
echo t
echo 2
echo 19
echo n
echo 3
echo 
echo 
echo w
) | fdisk /dev/sda