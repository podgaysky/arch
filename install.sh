ls /sys/firmware/efi/efivars
timedatectl set-ntp true
fdisk -u -p /dev/whatever <<EOF
n
p
1
w
EOF
