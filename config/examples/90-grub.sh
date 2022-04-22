#!/bin/bash

#
# This copies over your GRUB values to the new rootfs and reruns update-grub.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

: "${GRUB_NO_COPY_CONFIG:=0}"

if [ "${GRUB_NO_COPY_CONFIG}" -eq 0 ]
then
    echo "Copying GRUB config values from current install…" >&2
    run --write tee /etc/default/grub >/dev/null </etc/default/grub
else
    echo "Skipping copying GRUB config values from current install." >&2
exit

run --write update-grub
