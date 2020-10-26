#!/bin/sh

set -exo pipefail

# EXPERIMENTAL

function install_packages {
   install_official_packages
   install_unofficial_packages
}

function install_official_packages {
   echo 'pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort pkglist.txt))'
}

function install_unofficial_packages {
   #TODO: install yay and AUR packages
   echo
}

function encrypt_extra_disks {
   for d in $(lsblk -ndo NAME); do
      WWNID="$(udevadm info -q property --name $d | awk -F= '/ID_WWN=/ {print $2}')"
      UUID="$(sudo blkid -s UUID -o value /dev/$d)"
      TYPE="$(sudo blkid -s TYPE -o value /dev/$d)"
      PTTYPE="$(sudo blkid -s PTTYPE -o value /dev/$d)"

      if [[ -n "$WWNID" ]] && [[ -z "$UUID" ]] && [[ -z "$TYPE" ]] && [[ -n "$PTTYE" ]]; then
         LUKS_DIR="/etc/luks-keys"
         LUKS_KEY="$LUKS_DIR/wwn-$WWNID"
         DISK_NAME="disk-$WWNID"

         echo sudo mkdir "$LUKS_DIR" || true
         echo Generating encryption key for $d...
         echo sudo dd if=/dev/random of="$LUKS_KEY" bs=0 count=256

         echo Encrypting $d...
         echo sudo crytsetup open -d "$LUKS_KEY" --type luks /dev/$d "$DISK_NAME"

         UUID="$(sudo blkid -s UUID -o value /dev/$d)"
         echo sudo sh -c "echo -e $DISK_NAME\tUUID=$UUID\t$LUKS_KEY >> /etc/crypttab"
         echo sudo find "$LUKS_DIR" -type f -exec chmod 600 {} \;

         # TODO: Add yubikey support
      fi
   done
}

install_packages
encrypt_extra_disks
