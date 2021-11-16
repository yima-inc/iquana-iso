ARCHIVE=install-cockpit-plugins.tgz

STAGING=install-cockpit-plugins

FILES=\
	$(STAGING)/install-cockpit-plugins.sh \
	$(STAGING)/iquana-agent/index.html \
	$(STAGING)/iquana-agent/index.js \
	$(STAGING)/iquana-agent/manifest.json \
	$(STAGING)/iquana-server/index.html \
	$(STAGING)/iquana-server/index.js \
	$(STAGING)/iquana-server/manifest.json

.PHONY: all
all: dist

.PHONY: clean
clean:
	rm -rf \
		$(ARCHIVE) \
		$(STAGING)

.PHONY: dist
dist: $(ARCHIVE)

$(ARCHIVE): $(FILES)
	tar -z -c -f $@ $(FILES)

$(STAGING)/%: %
	mkdir -p $(dir $@)
	cp $< $@
