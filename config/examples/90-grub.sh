#!/bin/bash

#
# This copies over your GRUB values to the new rootfs and reruns update-grub.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

run --write tee /etc/default/grub >/dev/null </etc/default/grub
run --write update-grub
