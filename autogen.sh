#!/bin/bash

#
# Author: Carl Kittelberger <icedream@icedream.pw>
#

set -e
set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$SCRIPT_DIR" > /dev/null

log() {
    if [ "$#" -gt 0 ]
    then
        echo "$@" >&2
        return
    fi
    cat >&2
}

run() {
    log 'running:' "$@"
    "$@"
}

run autoreconf -fvi

log <<'EOF'

You can now configure the project with ./configure and build it with make.
Run `./configure --help` for configuration options.
EOF
