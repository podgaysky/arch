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