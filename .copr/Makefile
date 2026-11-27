# COPR "make_srpm" method: make -f .copr/Makefile srpm outdir=DIR
top := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
outdir ?= $(top)/srpm
specfile := $(top)/packaging/rpm/ltcodes.spec

srpm:
	dnf -y install rpmdevtools rpm-build
	mkdir -p $(outdir)
	spectool -g -C $(outdir) $(specfile)
	rpmbuild -bs --define "_sourcedir $(outdir)" --define "_srcrpmdir $(outdir)" $(specfile)
