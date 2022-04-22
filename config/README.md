# SteamOS permanent modification scripts directory

This directory is scanned by steamos-permanent-mods to modify your SteamOS copy on
each update. Scanning does not happen recursively, and all scripts must end with
`.sh`.

All scripts are executed in alphabetical order. For example, we ship some
scripts by default that are prefixed with `00-` which will be run first, then
`10-` will be run next, `20-` after that etc.

The shipped scripts include comments explaining what they do and why they do the
things they do. Please strongly consider reading these comments.

Note that if something breaks somewhere in a script, that's game over for an
attempt at updating SteamOS. All scripts are intentionally executed with shell
flags `-e` and `-u` set to avoid unintended breakage of your system post-reboot
due to such mistakes.

You can test your scripts by forcing an update with this command as `root` user:

    /usr/sbin/steamos-atomupd-client --manifest /usr/share/steamos-update/manifest-0.json

This will trigger a download and install of the latest SteamOS stable version.
Add `--variant=steamdeck-beta` for Beta and `-d` to see all of the update
process output, including your scripts' output. Do consider `echo "your text
here" >&2` in your script for debug output.

Feel free to study, modify and include these files to your needs!

## Scripting reference

This is just an overview of exposed commands that user scripts can use to run
their modifications.

### `run`

Runs a command in any of the partsets, by default on the 'other' (updated)
partset.

You can pass flags before passing the actual command and arguments to run:

- Pass --slot=self to run a command on 'self' partset instead of the default
  'other'. You can also pass A or B directly.
- Pass --write to remove immutability temporarily to run the given command.

Examples:

- Run lspci on current SteamOS install:
  `run --slot=self lspci`
- Run pacman on other SteamOS install with readonly flag off:
  `run --write pacman -S --noconfirm --needed kdeconnect`

Note that in most situations you won't need `run --slot=self` and you can just
run the command directly – this is really just futureproofing for use cases
where you run this from recovery or something like that.
