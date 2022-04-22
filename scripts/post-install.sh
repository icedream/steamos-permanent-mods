#!/bin/bash

#
# Steam Mutator
#
# rauc post-install hook script.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

set -e
set -u

###

STEAMOS_POSTINSTALL=/usr/lib/rauc/post-install.sh
DRY_RUN=0

# NOTE - see https://rauc.readthedocs.io/en/v1.6/reference.html#custom-handlers-interface for additional predefined variables

###

while [ "$#" -gt 0 ] && [[ "$1" =~ ^-(.+)$ ]]
do
    name="${BASH_REMATCH[1]}"
    shift 1

    # handle different option styles
    if [[ "$name" = "-" ]]
    then
        # arg separator (--), do not process any further
        break
    elif [[ "$name" =~ ^\-(.+)$ ]]
    then
        # long syntax (--name, --name=value, --name value)
        name="${BASH_REMATCH[1]}"

        # treat syntax --name=value in a way that still allows --name only
        if [[ "$name" =~ ^(.+)=(.*)$ ]]
        then
            name="${BASH_REMATCH[1]}"
            # move value back into args to allow case block below to handle it
            set -- "${BASH_REMATCH[2]}" "$@"
        fi
    else
        # short syntax (-N, -Nvalue, -N value)

        # treat syntax -Nvalue in a way that still allows -N only
        if [[ "$name" =~ ^(.)(.+)$ ]]
        then
            name="${BASH_REMATCH[1]}"
            # move value back into args to allow case block below to handle it
            set -- "${BASH_REMATCH[2]}" "$@"
        fi
    fi

    case "$name" in
    s|skip-original-postinstall)
        STEAMOS_POSTINSTALL=
        ;;
    d|dry-run)
        DRY_RUN=1
        ;;
    h|help)
        echo "usage: $0 [--dry-run | -d] [--help | -h] [--skip-original-postinstall | -s]" >&2
        exit
        ;;
    esac
done

###

echo "Dry run mode: $DRY_RUN" >&2

# run original SteamOS rauc post-install hook
if [ "$DRY_RUN" -eq 0 ]
then
    if [ -n "$STEAMOS_POSTINSTALL" ]
    then
        "${STEAMOS_POSTINSTALL}"
    else
        echo "* Skipping SteamOS post-install.sh script" >&2
    fi
else
    echo "* Skipping SteamOS post-install.sh script due to --dry-run" >&2
fi

###

SYMLINKS_DIR=/dev/disk/by-partsets

# [ -e /usr/lib/steamos/steamos-partitions-lib ] && \
#     . /usr/lib/steamos/steamos-partitions-lib  || \
#     { echo "Failed to source '/usr/lib/steamos/steamos-partitions-lib'"; exit 1; }

# detect current and other partset
declare -r "BOOTED_SLOT=$(steamos-bootconf this-image || true)"
PRESERVED_SLOT=
UPDATED_SLOT=

case "${BOOTED_SLOT}" in
    A)
        PRESERVED_SLOT=A
        UPDATED_SLOT=B
        # ROOT_DEVICE_SELF=$(realpath $SYMLINKS_DIR/self/rootfs)
        # ROOT_DEVICE_OTHER=$(realpath $SYMLINKS_DIR/other/rootfs)
        ;;
    B)
        PRESERVED_SLOT=B
        UPDATED_SLOT=A
        # ROOT_DEVICE_SELF=$(realpath $SYMLINKS_DIR/self/rootfs)
        # ROOT_DEVICE_OTHER=$(realpath $SYMLINKS_DIR/other/rootfs)
        ;;
    *)
        while read valid slot x
        do
            case $valid$slot in
                +A)
                    UPDATED_SLOT=B
                    PRESERVED_SLOT=A
                    ;;
                +B)
                    UPDATED_SLOT=A
                    PRESERVED_SLOT=B
                    ;;
            esac
        done < <(steamos-bootconf list-images)
        ;;
esac

ROOT_DEVICE_SELF=$(realpath $SYMLINKS_DIR/$PRESERVED_SLOT/rootfs)
ROOT_DEVICE_OTHER=$(realpath $SYMLINKS_DIR/$UPDATED_SLOT/rootfs)

# Returns where the device $1 is mounted, otherwise only fails.
find_mount() {
    local device=$1

    findmnt --real -n -o TARGET -f --source "$device"
}

# Runs a command in any of the partsets, by default on the 'other' (updated) partset.
#
# You can pass flags before passing the actual command and arguments to run:
#
# - Pass --slot=self to run a command on 'self' partset instead of the default 'other'. You can also pass A or B directly.
# - Pass --write to remove immutability temporarily to run the given command.
#
# Syntax:
#   [--slot | -s self]
#   [--write | -w]
#   [--]
#   command args...
run() {
    local slot
    local device
    local write
    local name
    local mountpath
    local shellpref
    local onexit
    device=
    slot=other
    write=0
    while [ "$#" -gt 0 ] && [[ "$1" =~ ^-(.+)$ ]]
    do
        name="${BASH_REMATCH[1]}"
        shift 1

        # handle different option styles
        if [[ "$name" = "-" ]]
        then
            # arg separator (--), do not process any further
            break
        elif [[ "$name" =~ ^\-(.+)$ ]]
        then
            # long syntax (--name, --name=value, --name value)
            name="${BASH_REMATCH[1]}"

            # treat syntax --name=value in a way that still allows --name only
            if [[ "$name" =~ ^(.+)=(.*)$ ]]
            then
                name="${BASH_REMATCH[1]}"
                # move value back into args to allow case block below to handle it
                set -- "${BASH_REMATCH[2]}" "$@"
            fi
        else
            # short syntax (-N, -Nvalue, -N value)

            # treat syntax -Nvalue in a way that still allows -N only
            if [[ "$name" =~ ^(.)(.+)$ ]]
            then
                name="${BASH_REMATCH[1]}"
                # move value back into args to allow case block below to handle it
                set -- "${BASH_REMATCH[2]}" "$@"
            fi
        fi

        case "$name" in
        # d|device)
        #     device="$1"
        #     shift 1
        #     ;;
        s|slot)
            slot="$1"
            shift 1
            ;;
        w|write)
            write=1
            ;;
        *)
            echo "ERROR: Unknown option $name passed to run command." >&2
            exit 1
            ;;
        esac
    done

    if [ "$DRY_RUN" -ne 0 ] && [ "$slot" = "$UPDATED_SLOT" ]
    then
        echo "* Would run on slot $slot, skipping due to --dry-run:" "$@" >&2
        return
    else
        echo "* Running on slot $slot:" "$@" >&2
    fi

    case "$slot" in
    other)
        slot="$UPDATED_SLOT"
        device="$ROOT_DEVICE_OTHER"
        ;;
    self)
        slot="$PRESERVED_SLOT"
        device="$ROOT_DEVICE_SELF"
        ;;
    esac

    shellpref=''
    onexit=''

    # TODO - get actual subprocess killing working
    # shellpref='
    # ___kill_all_subprocesses() {
    #     pids=();
    #     for pid in $(ps -s $$ -o pid=);
    #     do
    #         if [ $pid -eq $$ ];
    #         then
    #             continue;
    #         fi;
    #         pids+=($pid);
    #     done;
    #     kill "${pids[@]}";
    #     for i in $(seq 0 10); do
    #         if kill -0 "${pids[@]}" 2>/dev/null >/dev/null;
    #         then
    #             sleep 1;
    #             continue;
    #         fi;
    #         break;
    #     done;
    #     if kill -0 "${pids[@]}" 2>/dev/null >/dev/null;
    #     then
    #         kill -9 "${pids[@]}" 2>/dev/null >/dev/null;
    #     fi;
    # };'
    # NOTE - for now we are just working around gpg-agent holding /dev
    # shellpref+='___kill_all_subprocesses() { while killall -0 gpg-agent >/dev/null 2>/dev/null; do killall gpg-agent; sleep 0.25; done; };'
    onexit+='while killall -0 gpg-agent >/dev/null 2>/dev/null; do killall gpg-agent; sleep 0.25; done;'

    if [ "$write" -ne 0 ]
    then
        # rewrite command so it makes the partset temporarily mutable first
        # TODO - add explicit btrfs ro flag set call to support running on a chroot from a recovery image
        shellpref+='
        ___should_enable_readonly=0;
        mount -o remount,rw /;
        if [[ $(btrfs property get / ro) = "ro=true" ]];
        then
            ___should_enable_readonly=1;
            btrfs property set / ro false;
        fi;'
        onexit+='
        if [ $___should_enable_readonly -ne 0 ];
        then
            btrfs property set / ro true;
        fi;'
    fi

    # see /usr/lib/systemd/system/steamos-offload.target.wants/*.mount
    if [ "${SKIP_OFFLOAD:-0}" -eq 0 ]
    then
        for offloadpath in $(SKIP_OFFLOAD=1 run sh -c 'grep -hPo '"'"'Where=\K.+'"'"' /usr/lib/systemd/system/steamos-offload.target.wants/*.mount') \
    ;
        do
            # Since it's a bad idea to modify currently mounted shared stuff from the new image, use a tmpfs as a stub
            # NOTE - order of mount/umount does not seem to matter… for now…
            # TODO - Do we have better ideas to achieve full functionality here?
            shellpref+="mount -t tmpfs /home/.steamos/offload/$offloadpath $offloadpath &&"
            onexit+="umount $offloadpath || exit 1;"
        done
    fi

    # Do we want to set up network connection?
    if [ -f /etc/resolv.conf ] && [ "${SKIP_RESOLVCONF:-0}" -eq 0 ]
    then
        # Yep, create temporary file and bind it on top of existing /etc/resolv.conf to apply network configuration
        shellpref+='base64 -d >/tmp/resolv.conf <<<"'"$(base64 -w0 < /etc/resolv.conf)"'" && mount -o bind /tmp/resolv.conf /etc/resolv.conf || exit 1;'
        onexit+='umount /etc/resolv.conf || exit 1;'
    fi

    # Convert $onexit to a proper on-exit trap command
    if [ -n "$onexit" ]
    then
        shellpref+='trap '"'$onexit'"' EXIT;'
    fi

    # Wrap command with our prefix script
    if [ -n "$shellpref" ]
    then
        set bash -c "$shellpref"' "$@"' -- "$@"
    fi

    mountpath="$(find_mount "$device" || true)"
    if [ -n "$mountpath" ]
    then
        if [ "$device" = "$ROOT_DEVICE_SELF" ] && [ "$mountpath" = "/" ]
        then
            # We are booted on the old SteamOS copy at the moment, un directly
            "$@"
        else
            # Assume prepared chroot, run command in there
            chroot "$mountpath" "$@"
        fi
    else
        # Chroot into old SteamOS copy
        steamos-chroot --partset "$slot" -- "$@"
    fi
}

##############################################################################

# if there is a default variables file, read it to make values available to user
# scripts
if [ -f /usr/local/etc/default/steamos-permanent-mods ]
then
    echo "Loading values from" /usr/local/etc/default/steamos-permanent-mods >&2
    . /usr/local/etc/default/steamos-permanent-mods
fi

while IFS= read -r -d $'\0' file; do
    # run script in subshell to avoid one script poisoning the environment for
    # other scripts
    (
        echo "Running user script" "$file" >&2
        . "$file"
    )
done < <(
    # only scan directly in config dir, do not recurse
    find /usr/local/etc/steamos-permanent-mods -mindepth 1 -maxdepth 1 -name '*.sh' \( -type f -or -type l \) -print0 |\
    sort -z
)

###

# Configure our post-install hook in rauc
echo "Installing" steamos-permanent-mods "and user scripts…" >&2
run --write sed -i 's,post-install=\(.\+\),#post-install=\1\npost-install='"${BASH_SOURCE[0]}"',g' /etc/rauc/system.conf
tar -c -C / \
    "${BASH_SOURCE[0]}" \
    /usr/local/share/steamos-permanent-mods \
    /usr/local/lib/steamos-permanent-mods \
    /usr/local/etc/steamos-permanent-mods \
    |\
run --write tar -x -v -C /
