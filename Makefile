ifndef BUILDTAG
BUILDTAG=dev
endif

PROJ_NAME=iquana
ISONAME=ubuntu-20.04.1-live-server-amd64

SRC_ISO=$(ISONAME).iso
DST_ISO=$(PROJ_NAME).$(BUILDTAG).iso

STAGING=_staging

STAGING_FILES:=\
	$(STAGING)/build-iso.sh \
	$(STAGING)/$(SRC_ISO) \
	$(STAGING)/custom/meta-data \
	$(STAGING)/custom/user-data \
	$(STAGING)/custom/provision.sh \
	$(STAGING)/custom/firstboot/delay-exec.sh \
	$(STAGING)/custom/firstboot/firstboot.sh \
	$(STAGING)/custom/firstboot/install-cockpit-plugins.tgz \
	$(STAGING)/custom/firstboot/install-custom-images.tgz \
	$(STAGING)/custom/firstboot/install-deb-packages.tgz \
	$(STAGING)/custom/firstboot/install-k3s-installer.tgz

ARCHIVE_NAME:=iquana-iso
ARCHIVE:=$(ARCHIVE_NAME).tar.gz

.PHONY: all
all: $(STAGING)/$(DST_ISO)

.PHONY: clean
clean:
	make -C custom/firstboot/install-cockpit-plugins clean
	make -C custom/firstboot/install-custom-images clean
	make -C custom/firstboot/install-deb-packages clean
	make -C custom/firstboot/install-k3s-installer clean
	rm -rf \
		$(STAGING) \
		$(ARCHIVE)

.PHONY: veryclean
veryclean: clean
	rm -rf \
		$(SRC_ISO)

.PHONY: dist
dist: $(ARCHIVE)

$(ARCHIVE):
	git archive \
		--format=tar.gz \
		--prefix=$(ARCHIVE_NAME)/ \
		-o $@ \
		HEAD \
		build-iso.sh \
		custom/ \
		Makefile

$(STAGING)/$(DST_ISO): $(STAGING_FILES)
	cd $(STAGING) && sh build-iso.sh $(SRC_ISO) $(DST_ISO) $(shell echo $(PROJ_NAME) | head -c16).$(BUILDTAG)

$(STAGING)/custom/firstboot/firstboot.sh: custom/firstboot/firstboot.sh
	mkdir -p $(dir $@)
	cp $< $@

$(STAGING)/custom/firstboot/install-cockpit-plugins.tgz: custom/firstboot/install-cockpit-plugins/install-cockpit-plugins.tgz
	mkdir -p $(dir $@)
	cp $< $@

custom/firstboot/install-cockpit-plugins/install-cockpit-plugins.tgz:
	$(MAKE) -C custom/firstboot/install-cockpit-plugins dist

$(STAGING)/custom/firstboot/install-custom-images.tgz: custom/firstboot/install-custom-images/install-custom-images.tgz
	mkdir -p $(dir $@)
	cp $< $@

custom/firstboot/install-custom-images/install-custom-images.tgz:
	$(MAKE) -C custom/firstboot/install-custom-images dist

$(STAGING)/custom/firstboot/install-deb-packages.tgz: custom/firstboot/install-deb-packages/install-deb-packages.tgz
	mkdir -p $(dir $@)
	cp $< $@

custom/firstboot/install-deb-packages/install-deb-packages.tgz:
	$(MAKE) -C custom/firstboot/install-deb-packages generate-filelist
	$(MAKE) -C custom/firstboot/install-deb-packages dist

$(STAGING)/custom/firstboot/install-k3s-installer.tgz: custom/firstboot/install-k3s-installer/install-k3s-installer.tgz
	mkdir -p $(dir $@)
	cp $< $@

custom/firstboot/install-k3s-installer/install-k3s-installer.tgz:
	$(MAKE) -C custom/firstboot/install-k3s-installer dist

$(STAGING)/custom/%: custom/%
	mkdir -p $(dir $@)
	cp $< $@

$(STAGING)/custom/meta-data:
	mkdir -p $(dir $@)
	touch $@

$(STAGING)/$(SRC_ISO): $(SRC_ISO)
	mkdir -p $(dir $@)
	cp $< $@

$(SRC_ISO):
	curl -s --output $@ http://old-releases.ubuntu.com/releases/20.04.1/ubuntu-20.04.1-live-server-amd64.iso

$(STAGING)/%: %
	mkdir -p $(dir $@)
	cp $< $@
