IMAGES=\
	ubuntu:focal

STAGING=install-custom-images
FILES=\
	$(STAGING)/install-custom-images.sh \
	$(STAGING)/usr/share/iquana/custom-images/custom-images.tar.gz

.PHONY: all
all: dist

.PHONY: clean
clean:
	rm -rf \
		install-custom-images.tgz \
		$(STAGING)

.PHONY: dist
dist: install-custom-images.tgz

install-custom-images.tgz: $(FILES)
	tar -z -c -f $@ $(FILES)

$(STAGING)/usr/share/iquana/custom-images/custom-images.tar.gz:
	for IMAGE in $(IMAGES); do \
		docker pull $$IMAGE || exit 1; \
	done
	mkdir -p $(dir $@)
	docker save $(IMAGES) | pigz > $@

$(STAGING)/%: %
	mkdir -p $(dir $@)
	cp $< $@
