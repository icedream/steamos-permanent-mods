SUBDIRS = config config/examples scripts

dist_doc_DATA = CHANGELOG.md KNOWN_BUGS.md README.md

EXTRA_DIST = VERSION

# an odd way to say rerun autotools if git metadata changed
Makefile: .git/index

# baked-in version metadata for source dist
VERSION: .git/index tools/version.sh
	tools/version.sh > $@

dist: VERSION
