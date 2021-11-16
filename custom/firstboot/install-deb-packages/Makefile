STAGING=install-deb-packages

PACKAGES=\
	atop \
	cockpit \
	cockpit-networkmanager \
	cockpit-storaged \
	iotop \
	ncdu \
	nfs-kernel-server \
	smartmontools \
	socat \
	traceroute \
	tree \
	vim

include packages.mk

ROOT_PACKAGES+=\
	$(PACKAGES) \
	$(AUTO_PACKAGES) \
	$(MANUAL_PACKAGES) \

-include deblist.mk

FILES=\
	$(DEBLIST) \
	$(STAGING)/apt-repo/Packages.gz \
	$(STAGING)/install-deb-packages.sh

.PHONY: all
all: $(FILES)

.PHONY: clean
clean:
	rm -rf \
		$(STAGING) \
		deblist.mk \
		install-deb-packages.tgz

.PHONY: dist
dist: install-deb-packages.tgz

.PHONY: download
download: $(DEBLIST)

.PHONY: generate-filelist
generate-filelist:
	$(eval root_package_list=$(ROOT_PACKAGES))
	$(eval root_package_version_list=$(shell apt-cache madison $(root_package_list) | sort -u -k1,1 | awk '{print $$1 "=" $$3}' | sort -u))
	$(eval package_list=$(shell apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $(root_package_version_list) | grep "^\w" | sort -u))
	$(eval package_version_list=$(shell apt-cache madison $(package_list) | sort -u -k1,1 | awk '{print $$1 "=" $$3}' | sort -u))
	$(eval _deb_file_list=$(shell apt-get download --print-uris $(package_version_list) | awk '{print $$2}'))
	$(eval deb_file_list=$(addprefix $(STAGING)/apt-repo/,$(_deb_file_list)))

	cat deblist.mk.in \
		| sed -e 's|%PKGLIST%|$(package_version_list)|g' \
		| sed -e 's|%DEBLIST%|$(deb_file_list)|g' \
		> deblist.mk

$(STAGING)/apt-repo/Packages.gz: FORCE $(DEBLIST)
	mkdir -p $(dir $@)
	cd $(dir $@) && \
		dpkg-scanpackages --arch amd64 . /dev/null | gzip -9c > Packages.gz

$(STAGING)/apt-repo/%.deb:
	mkdir -p $(dir $@)
	cd $(dir $@) && \
		apt-get download $(PKGLIST)

$(STAGING)/install-deb-packages.sh: install-deb-packages.sh.in
	mkdir -p $(dir $@)
	cat $< | sed -e 's|@PACKAGES@|$(PACKAGES)|g' > $@

install-deb-packages.tgz: $(FILES)
	tar -z -c -f $@ $(FILES)

FORCE: ;
