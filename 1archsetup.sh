#!/bin/sh
timedatectl set-ntp true
echo "1. Select gpt"
echo "2. Make a new 500M part, select EFI -- sda1"
echo "The new partition below is the hard drive minus 500M and 1G"
echo "For a 20G drive, do 18.5G."
echo "3. Make a new partition, just hit enter. sda2"
echo "4. Make a new 1G part, select swap -- sda3"
read -p "Press Enter to continue" </dev/tty
cfdisk /dev/sda
mkswap /dev/sda3
swapon /dev/sda3
mkfs.fat -F32 /dev/sda1
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux linux-firmware -y
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
# Edit this with whatever time zone to use!
ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime
pacman -S vim nano --noconfirm
echo "Change what languages you need"
read -p "Press Enter to continue" </dev/tty
nano /etc/locale.gen
locale-gen
touch /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Add the hostname"
read -p "Press Enter to continue" </dev/tty
nano /etc/hostname
echo "The hosts should look similar to this, replacing hostname with the hostname you set"
echo "127.0.0.1   localhost
::1         localhost
127.0.1.1   hostname.localdomain  hostname"
read -p "Press Enter to continue" </dev/tty
nano /etc/hosts
systemctl enable systemd-networkd
systemctl enable systemd-resolved
echo "[Match]
Name=ens33

[Network]
DHCP=yes" > /etc/systemd/network/20-wired.network
passwd
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
umount -R /mnt
reboot
