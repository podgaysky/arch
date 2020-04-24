ls /sys/firmware/efi/efivars
timedatectl set-ntp true
fdisk -u -p /dev/whatever <<EOF
g
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
