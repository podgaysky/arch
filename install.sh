ls /sys/firmware/efi/efivars
timedatectl set-ntp true
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
g
n
1

+550M
t
1
n
2

+1024M
t
2
19
n
3


w
EOF