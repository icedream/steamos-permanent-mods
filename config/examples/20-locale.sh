#
# Copy over locale files, useful for Desktop mode since quite a few apps depend
# on this to be set properly (time display, currencies, even displayed language
# on websites).
#
# To set up system locale:
#
# 1. Uncomment the locale you want in /etc/locale.gen.
# 2. Reinstall glibc to restore the locale-gen command. (Or if already done so
#    run locale-gen.)
# 3. Use `localectl set-locale LANG=<yourlocale> …` to set the system locale
#    variables.
#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

# Copy locale.gen from current install
run --write tee /etc/locale.gen </etc/locale.gen >/dev/null

# Or modify SteamOS' preinstalled locale.gen with this
#run --write sed -i 's,#\(de_DE.UTF-8\),\1,' /etc/locale.gen

# Reinstall glibc if locale-gen is stripped out
# NOTE - pacman automatically runs locale-gen for us
(run test -f /usr/bin/locale-gen && run --write locale-gen) ||\
    run --write pacman -S --noconfirm glibc

# Copy over locale configuration from current install
run --write localectl set-locale $(cat /etc/locale.conf)

# Or fixate locales independently from current configuraiton like this:
#run --write localectl set-locale LANG=de_DE.UTF-8 LC_MESSAGES=en_US.UTF-8
