#!/bin/bash

#
# User script for replicable system modifications, specifically for non-Deck
# hardware.
#
# Run this after 00-pacman.sh (and 10-pacman-unstrip.sh) as well as any script
# that reinstalls gamescope somehow.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

##############################################################################
# Variables set by PCI hardware detection code below

# Whether we got the Deck's Van Gogh GPU.
# This is important for graphics to initialize properly on boot up on anything that isn't Van Gogh GPU.
# 0=install linux-firmware, 1=keep linux-firmware-neptune
deck_gpu=1

# Whether we got a VMware GPU.
# 0=do nothing, 1=install open-vm-tools
vmware=0

# Whether we got a Virtualbox GPU.
# 0=do nothing, 1=install virtualbox-guest-tools
virtualbox=0

# This code detects hardware based on PCI IDs and sets respective variables.
#
# To get an overview of PCI devices line by line, use `lspci` and then add `-n` flag to get the hex values.
#
# For example, if we run `lspci` on the Deck we can see this:
#
#   04:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] VanGogh (rev ae)
#
# That is the Deck's GPU! Running `lspci -n | grep 04:00.0` then gives us:
#
#   04:00.0 0300: 1002:163f (rev ae)
#
# 1002 is the vendor ID and 163f is the device ID. We put this together to 1002:163f for this script's filtering mechanism.
while read -ra dev
do
    dev=("${dev[@]//\"/}")
    slot="${dev[0]}"
    class="${dev[1]}"
    vendor="${dev[2]}"
    device="${dev[3]}"
    case "$class:$vendor:$device" in
    0300:*)
        case "$vendor:$device" in
        1002:163f)
            # Deck's AMD Van Gogh GPU
            deck_gpu=1
            ;;
        15ad:0405)
            # VMware GPU
            deck_gpu=0
            vmware=1
            ;;
        # ????:????)
        #     # TODO - VirtualBox GPU. Leaving this as an exercise to whoever wants to do this. :-)
        #     deck_gpu=0
        #     virtualbox=1
        #     ;;
        *)
            # some other GPU, definitely install linux-firmware
            deck_gpu=0
            ;;
        esac
        ;;
    esac
done < <(lspci -nmm)

# For non-Decks, replace linux-firmware-jupiter with linux-firmware
# (`yes y` confirms the conflict replacement prompt to nuke linux-firmware-jupiter)
if [ "$deck_gpu" -eq 0 ]
then
    yes y | run --write pacman -S linux-firmware

    # Remove specific linux kernel parameters that SteamOS sets for the Deck hardware
    # (sed pattern \?\+ just gets rid of extra space character if one exists)
    run --write sed -i \
        -e 's,amdgpu.gttsize=8128 \?\+,,g' \
        -e 's,sp_amd.speed_dev=1 \?\+,,g' \
        /etc/default/grub \
        /etc/default/grub-legacy \
        /etc/default/grub-steamos
    run --write update-grub

    # Fix Steam's Deck UI not stretching to whole resolution on external HDMI
    # NOTE - this has to be after reinstalling gamescope, otherwise this gets overwritten
    run --write sed -i 's,"-steamos3" ,,' /usr/bin/gamescope-session
fi

# Install open-vm-tools for VMware
if [ "$vmware" -ne 0 ]
then
    run --write pacman -S --noconfirm open-vm-tools
fi

# Install virtualbox-guest-utils for VirtualBox
# TODO - this is yet untested
if [ "$virtualbox" -ne 0 ]
then
    run --write pacman -S --noconfirm virtualbox-guest-utils
    run --write systemctl enable vboxservice.service

    # replicate the Deck's original screen resolution
    run --write VBoxManage setextradata "Arch Linux" "CustomVideoMode1" "1280x800x24"
fi
