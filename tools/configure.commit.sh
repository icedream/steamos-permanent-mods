#!/bin/sh

#
# Revision script for configure script specifically.
# Pretty much a copy of https://stackoverflow.com/a/15376953.
#

# Display the SHA1 of the commit in which configure.ac was last modified.
# If it's not checked in yet, use the SHA1 of HEAD plus -dirty.

if [ ! -d .git ] ; then
    # if no .git directory, assume they're not using Git
    printf 'unknown commit'
elif git diff --quiet HEAD -- configure.ac ; then
    # configure.ac is not modified
    printf 'commit %s' `git rev-list --max-count=1 HEAD -- configure.ac`
else # configure.ac is modified
    printf 'commit %s-dirty' `git rev-parse HEAD`
fi
