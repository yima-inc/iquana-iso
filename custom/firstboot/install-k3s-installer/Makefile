K3S_VERSION=v1.20.7+k3s1

STAGING=install-k3s-installer

FILES=\
	$(STAGING)/etc/default/iquana \
	$(STAGING)/install-k3s-installer.sh \
	$(STAGING)/lib/systemd/system/iquana-relay.service \
	$(STAGING)/usr/local/bin/iquana-agent.sh \
	$(STAGING)/usr/local/bin/iquana-prepare.sh \
	$(STAGING)/usr/local/bin/iquana-relay.sh \
	$(STAGING)/usr/local/bin/iquana-reset.sh \
	$(STAGING)/usr/local/bin/iquana-server.sh \
	$(STAGING)/usr/share/k3s/install.sh \
	$(STAGING)/usr/share/k3s/k3s \
	$(STAGING)/usr/share/k3s/k3s-airgap-images-amd64.tar.gz

.PHONY: all
all: download

.PHONY: clean
clean:
	rm -rf \
		$(STAGING) \
		install-k3s-installer.tgz

.PHONY: dist
dist: install-k3s-installer.tgz

.PHONY: download
download: $(FILES)

$(STAGING)/usr/share/k3s/install.sh:
	mkdir -p $(dir $@)
	curl -o $@ https://get.k3s.io/

$(STAGING)/usr/share/k3s/k3s:
	wget --quiet -O $@ 'https://github.com/k3s-io/k3s/releases/download/$(K3S_VERSION)/k3s'

$(STAGING)/usr/share/k3s/k3s-airgap-images-amd64.tar.gz:
	wget --quiet -O- 'https://github.com/k3s-io/k3s/releases/download/$(K3S_VERSION)/k3s-airgap-images-amd64.tar' | gzip > $@

$(STAGING)/%: %
	mkdir -p $(dir $@)
	cp $< $@

install-k3s-installer.tgz: $(FILES)
	tar -z -c -f $@ $(FILES)
