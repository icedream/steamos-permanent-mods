libsubdir=$(libdir)/$(PACKAGE)
datasubdir = $(datadir)/$(PACKAGE)
sysconfsubdir = $(sysconfdir)/$(PACKAGE)

libsub_SCRIPTS = post-install.sh
CLEANFILES = $(libsub_SCRIPTS)
EXTRA_DIST = post-install.sh.in

edit = sed \
	-e 's|@bindir[@]|$(bindir)|g' \
	-e 's|@libdir[@]|$(libdir)|g' \
	-e 's|@libsubdir[@]|$(libsubdir)|g' \
	-e 's|@datadir[@]|$(datadir)|g' \
	-e 's|@datasubdir[@]|$(datasubdir)|g' \
	-e 's|@sysconfdir[@]|$(sysconfdir)|g' \
	-e 's|@sysconfsubdir[@]|$(sysconfsubdir)|g' \
	-e 's|@PACKAGE[@]|$(PACKAGE)|g' \
	-e 's|@prefix[@]|$(prefix)|g'

post-install.sh: post-install.sh.in Makefile
	rm -f $@ $@.tmp
	srcdir=''; \
	test -f ./$@.in || srcdir=$(srcdir)/; \
	$(edit) $${srcdir}$@.in >$@.tmp

	chmod +x $@.tmp
	chmod a-w $@.tmp
	mv $@.tmp $@
