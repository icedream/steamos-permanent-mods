SUBDIRS = examples

sysconfsubdir = $(sysconfdir)/$(PACKAGE)
dist_sysconfsub_DATA = README.md
CLEANFILES = README.md
EXTRA_DIST = README.md.in

edit = sed \
	-e 's|@bindir[@]|$(bindir)|g' \
	-e 's|@libdir[@]|$(libdir)|g' \
	-e 's|@libsubdir[@]|$(libsubdir)|g' \
	-e 's|@sysconfdir[@]|$(sysconfdir)|g' \
	-e 's|@PACKAGE[@]|$(PACKAGE)|g' \
	-e 's|@prefix[@]|$(prefix)|g'

README.md: README.md.in Makefile
	rm -f $@ $@.tmp
	srcdir=''; \
	test -f ./$@.in || srcdir=$(srcdir)/; \
	$(edit) $${srcdir}$@.in >$@.tmp

	mv $@.tmp $@
