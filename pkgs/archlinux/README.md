# Arch Install

UPDATED: 20160319

## LIVE ISO

Follows tutorial found here:
https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system###LUKS_on_LVM

### Setup root disk

- Check for Internet connection
```
$ ping 8.8.8.8
```

- Update system clock
```
$ timedatectl set-ntp true
```

- Identify devices
```
$ lsblk

- Partition main drive
```
$ parted /dev/sda
```

- Create a new partition table from a fresh drive 
```
(parted) mklabel msdos ### For MBR
or
(parted) mklabel gpt $ for UEFI
```

- Create two separated partitions. One for /boot (100MiB), one for LVM.
```
(parted) mkpart primary ext4 1MiB 100MiB ### For MBR
(parted) set 1 boot on
(parted) mkpart primary ext4 100MiB 100% 
or
(parted) mkpart ESP fat32 1MiB 513MiB ### For UEFI
(parted) set 1 boot on
(parted) mkpart primary ext4 513MiB 100%
```

- Now we will map the LVM and encrypt and create partitions,
  / (25GiB) swap (4GiB), and /home (all remaining space) 
  partitions will be created:
```
$ lvm pvcreate /dev/sda2
$ lvm vgcreate lvm /dev/sda2
$ lvm lvcreate -L 25G -n lvroot lvm
$ lvm lvcreate -L 4G -n swap lvm
$ lvm lvcreate -L 500M -n tmp lvm ### Only do if low RAM. Otherwise we will create a RAM disk
$ lvm lvcreate -l 100%FREE -n home lvm

$ cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 /dev/lvm/lvroot
$ cryptsetup open --type luks /dev/lvm/lvroot root
$ mkfs -t ext4 /dev/mapper/root
$ mount /dev/mapper/root /mnt
```

- Prepare the boot partition
```
$ dd if=/dev/zero of=/dev/sda1 bs=1M
$ mkfs -t ext4 /dev/sda1 ### For MBR
or
$ mkfs.fat -F32 /dev/sda1 ### For UEFI
$ mkdir /mnt/boot
$ mount /dev/sda1 /mnt/boot
```

- Install base packages
```
$ pacstrap -i /mnt base base-devel
```

- Setup fstab
```
genfstab -U /mnt >> /mnt/etc/fstab
```

- Change the root location
```
$ arch-chroot /mnt
```

### Chroot
- Setup hostname
```
$ echo <computer_name> > /etc/hostname
```

- Append hostname to /etc/hosts
```
$ vi /etc/hosts
----
localhost <hostname
```

- Setup localtime
```
$ ln -s /usr/share/zoneinfo/<zone>/<subzone> /etc/localtime
```

- Add the needed locales in /etc/locale.gen 
```
$ echo LANG=en_US.UTF-8 > /etc/locale.conf
```

- Uncomment en_US.UTF-8 in /etc/locale.gen
```
$ vi /etc/locale.gen
```

- Generate locales
```
$ locale-gen
```

- Adjust the time skew, and set the time standard to UTC
```
$ hwclock --systohc --utc
```

- Configure mkinitcpio. Add lvm2 and encrpy hooks to mkinicpio.conf
```
$ vi /etc/mkinitcpio.conf
-----
HOOKS="... block ''encrypt lvm2 ... filesystems ..."
```

- Rebuild kernel img
```
$ mkinitcpio -p linux
```

- install grub
```
$ pacman -S grub os-prober ### For MBR
$ grub-install --target=i386-pc --recheck --debug /dev/sda
or
$bootctl install ### UEFI
```

- Configure bootloader 
```
$ vi /etc/default/grub
-----
GRUB_CMDLINE_LINUX="cryptdevice=/dev/lvm/lvroot:cryptoroot root=/dev/mapper/cryptoroot" ### MBR
or
$ vi /boot/loader/loader.conf
-----

default  Arch Linux Encrypted
timeout  4
editor   0

$ vi /boot/loader/entries/arch-encrypted.conf
-----
title Arch Linux Encrypted
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=/dev/lvm/lvroot:cryptoroot root=/dev/mapper/cryptoroot
```

- Create grub config
```
$ grub-mkconfig -o /boot/grub/grub.cfg ### Don't run for UEFi
```

- Configure fstab and crypttab
```
$ vi /etc/fstab
-----
 /dev/mapper/root        /       ext4            defaults        0       1
 /dev/sda1               /boot   ext4            defaults        0       2
 /dev/mapper/tmp         /tmp    tmpfs           defaults        0       0
 /dev/mapper/swap        none    swap            sw              0       0

$ vi /etc/cryttab
-----
 swap   /dev/lvm/swap   /dev/urandom    swap,cipher=aes-xts-plain64,size=256
 tmp    /dev/lvm/tmp    /dev/urandom    tmp,cipher=aes-xts-plain64,size=256
```

### Configure the network interface to start automatically

- List network interfaces
```
ls /sys/class/net
```

- Enable on boot
```
$ systemctl enable dhcpcd@interface.service
```

- At this point reboot
```
$ exit
$ reboot
```

## First boot

-  Encrypt logical volume /home
```
$ mkdir -m 700 /etc/luks-keys
$ dd if=/dev/random of=/etc/luks-keys/home bs=1 count=256
$ cryptsetup luksFormat -v -s 512 -h sha512 /dev/lvm/home --key-file /etc/luks-keys/home
$ cryptsetup -d /etc/luks-keys/home open --type luks /dev/lvm/home home
$ mkfs -t ext4 /dev/mapper/home
$ mount /dev/mapper/home /home
```

- Add home parition to crypttab and fstab
```
$ vi /etc/fstab
----
/dev/mapper/home        /home   ext4        defaults        0       2

$ vi /etc/crypttab
----
home    /dev/lvm/home   /etc/luks-keys/home
```

- Add user, populate password and update finger
```
$ useradd -m -G wheel exampleuser
$ passwd exampleuser
$ chfn
```

- Allow wheel group sudoers
```
$ visudo
```

## Desktop Environment

- To install Gnome
```
$ sudo pacman -S gnome gdm
```

- To start gnome
```
$ sudo systemctl start gdm.services
```

## Extra disks: LUKs & BTRFS

- Create two disk encrypted btrfs. First create keys
```
$ dd if=/dev/random of=/etc/luks-keys/data0-btrfs bs=1 count=256
```

- Encrypt block devices
```
$ crytsetup open -d /etc/luks-keys/data0-btrfs --type luks /dev/sda btrfs-disk0
$ crytsetup open -d /etc/luks-keys/data0-btrfs --type luks /dev/sda btrfs-disk1
```

- Create btrfs filesystem
```
$ mkfs.btrfs -d raid1 -m raid1 /dev/mapper/btrfs-disk0 /dev/mapper/btrfs-disk1
```

- Mount the btrfs volume using any disk in the 
```
$ mkdir /mnt/storage-dev-btrfs && mount /mnt/storage-dev-btrfs/
```

- Add the volumes so that they decrypt on boot
```
$ cat /etc/crypttab
btrfs-disk0  UUID=256a669a-bdab-44f5-a606-51e121370f4f                            /etc/luks-keys/data0-btrfs
btrfs-disk1  UUID=a7f6e491-fb27-45fd-999f-85020f5b1be7                            /etc/luks-keys/data0-btrfs
```

- Create subvolumes
```
$ btrfs subvolume create /mnt/storage-dev-btrfs/home/exampleuser/music
```

- As you create subvolumes add them to your fstab. Example:
```
$ cat /etc/fstab
-----
UUID=00682d6e-c4f5-45d9-a59d-ceacac99d092       /mnt/media      btrfs           defaults,subvol=/mnt/media                      0 2
UUID=00682d6e-c4f5-45d9-a59d-ceacac99d092       /home/exampleuser/documents      btrfs               defaults,subvol=/home/exampleuser/documents                  0 2
UUID=00682d6e-c4f5-45d9-a59d-ceacac99d092       /home/exampleuser/pictures      btrfs                defaults,subvol=/home/exampleuser/pictures                   0 2
UUID=00682d6e-c4f5-45d9-a59d-ceacac99d092       /home/exampleuser/music      btrfs           defaults,subvol=/home/exampleuser/music                      0 2
```

## Verification

```
$ btrfs filesystem show ### Show btrfs fs
$ findmnt -nt btrfs ### List mounted btrfs volumes
$ lsblk --fs /dev/sda ### Show filesystem UUID
$ btrfs subvolume list <btrfs mnt>
```

## Decrypting Root Partition Remotely

See: https://www.adfinis-sygroup.ch/blog/en/decrypt-luks-devices-remotely-via-dropbear-ssh/


