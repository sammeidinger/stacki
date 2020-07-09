# @copyright@
# Copyright (c) 2006 - 2019 Teradata
# All rights reserved. Stacki(r) v5.x stacki.com
# https://github.com/Teradata/stacki/blob/master/LICENSE.txt
# @copyright@

OS=$(shell common/src/stack/build/build/bin/os)
RELEASE=$(shell common/src/stack/build/build/bin/os-release)
DISTRO=$(shell common/src/stack/build/build/bin/distribution)

ROLLROOT = .

-include $(ROLLSBUILD)/etc/CCRolls.mk

ifeq ($(OS),redhat)
BOOTABLE=1
endif

.PHONY: 3rdparty
3rdparty: # we need to do the for all OSes
	cd common && $(ROLLSBUILD)/bin/get3rdparty.py
	cd redhat && $(ROLLSBUILD)/bin/get3rdparty.py
	cd sles   && $(ROLLSBUILD)/bin/get3rdparty.py
	cd debian && $(ROLLSBUILD)/bin/get3rdparty.py

bootstrap-make:
	$(MAKE) -C $(OS) -f bootstrap.mk RELEASE=$(RELEASE) bootstrap
	$(MAKE) -C common/src/stack/build bootstrap

bootstrap: bootstrap-make
ifeq ($(STACKBUILD),)
	@echo
	@echo
	@echo Stacki build environment is now installed. Before you can
	@echo continue you will need to logout and login again. Then re-run
	@echo "make bootstrap" again.
	@echo
	@echo
	@/bin/false # stop the caller from continuing
endif
	$(MAKE) 3rdparty
	$(MAKE) -C common/src $@
	$(MAKE) -C $(OS) -f bootstrap.mk $@
	if [ -e $(OS)/src ]; then $(MAKE) -C $(OS)/src $@; fi


preroll::
	make -C common/src pkg
	if [ -e $(OS)/src ]; then make -C $(OS)/src pkg; fi
	make -C tools/fab pkg
	mkdir -p build-$(ROLL)-$(STACK)/graph
	mkdir -p build-$(ROLL)-$(STACK)/nodes

	mkdir -p build-$(ROLL)-$(STACK)/pallet_hooks/common
	mkdir -p build-$(ROLL)-$(STACK)/pallet_hooks/$(OS)
	cp common/graph/* build-$(ROLL)-$(STACK)/graph/
	cp common/nodes/* build-$(ROLL)-$(STACK)/nodes/
	if [ -e $(OS)/graph ]; then cp $(OS)/graph/* build-$(ROLL)-$(STACK)/graph/; fi
	if [ -e $(OS)/nodes ]; then cp $(OS)/nodes/* build-$(ROLL)-$(STACK)/nodes/; fi
# mkisofs fails because the directory structure is too deep in the build env
# for the version on sles11. We just simply skip this step for sles11 as the
# sles12 pallet holds all the hooks and initrds for sles11 anyways.
ifneq ($(RELEASE),sles11)
	-cp -r common/pallet_hooks/ build-$(ROLL)-$(STACK)/pallet_hooks/common/
	if [ -e $(OS)/pallet_hook ]; then cp -r $(OS)/pallet_hooks/ build-$(ROLL)-$(STACK)/pallet_hooks/$(OS)/; fi
endif




clean::
	rm -rf build-$(ROLL)-$(STACK)/graph/
	rm -rf build-$(ROLL)-$(STACK)/nodes/
	rm -rf build-$(ROLL)-$(STACK)/pallet_hooks/
