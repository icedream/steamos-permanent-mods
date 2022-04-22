# Process this file with autoconf to produce a configure script.

AC_INIT([steamos-permanent-mods], [m4_esyscmd([./tools/version.sh])], [icedream@icedream.pw])
AM_INIT_AUTOMAKE([foreign no-dist-gzip dist-xz tar-ustar subdir-objects])
AC_REVISION([m4_esyscmd([./tools/configure.commit.sh])])
AC_CONFIG_FILES([
    Makefile
    config/Makefile
    config/examples/Makefile
    scripts/Makefile
])
AC_OUTPUT
