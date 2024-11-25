#!/usr/bin/env bash
set -euo pipefail

ARGC=${#@}

# Pretty-printing
bold=$(tput bold)
blinking=$(tput blink)
reset=$(tput sgr0)

if [ "$ARGC" -ne 0 ] && [ "$ARGC" -ne 3 ]; then
	echo -e "\nError, please include 3 devices you want to format like this:
${bold}"$'\t'"$ ./$0 sdc sdd sde${reset}
You can also call the script without arguments to use ${bold}sdb, sdc, sdd${reset} as defaults."
	exit 1;
fi

read -p $'\n'"What do you want to name the pool? (Default: ${bold}zfs0${reset}): " pool_name
pool_name=${pool_name:-zfs0}
read -p $'\n'"Where do you want to mount the pool? (Default: ${bold}/mnt/${pool_name}${reset}: " mount_point
mount_point=${mount_point:-/mnt/${pool_name}}

drive1="${1:-"sdb"}"
drive2="${2:-"sdc"}"
drive3="${3:-"sdd"}"

read -p $'\n'"You're about to wipe the partition tables of
the following drives: ${bold}${drive1}, ${drive2} ${drive3}${reset}
The data will still be recoverable.

${blinking}${bold}***Are you sure you want to proceed?***${reset} [Y/n]: " answer
[ -z "$answer" ] && answer="Y"

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
	echo -e "\nExiting."
	exit 0;
fi

exit 0; # For testing purposes

# Wipe the file system info on all drives
for device in "$@"; do
	umount /dev/"${device}"?
	wipefs --all --force /dev/"$device"?
	wipefs --all --force /dev/"$device"
done

# Assemble raid5 pool
zpool create "$pool_name" raidz1 "$drive1" "$drive2" "$drive3" -f

# Set a mounting point

zfs set compression=off "$pool_name"
zfs set canmount=on "$pool_name"
zfs set mountpoint="$mount_point" "$pool_name"

echo -e "\nSuccessfully ran script!"

