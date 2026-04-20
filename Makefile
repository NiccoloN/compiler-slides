DESTDIR ?= .
PACKS := $(shell find src -name "Makefile" | awk -F/ 'NF == 3 { print $$2 }' | sort)
PACK ?=
DESTDIR_REAL := $(realpath $(DESTDIR))

.PHONY: all help list pack clean clean-pack $(PACKS)

all: $(PACKS)

help:
	@echo "Usage:"
	@echo "  make                 Build all slide packs"
	@echo "  make <pack>          Build a single slide pack (for example: make 30-mlir)"
	@echo "  make pack PACK=<pack> Build a single slide pack"
	@echo "  make clean           Clean all slide packs and published PDFs"
	@echo "  make clean PACK=<pack> Clean one slide pack and its published PDF"
	@echo "  make list            List available slide packs"

list:
	@printf '%s\n' $(PACKS)

pack:
	@if [ -z "$(PACK)" ]; then \
	  echo "PACK is required. Use 'make pack PACK=<pack>'."; \
	  exit 1; \
	fi
	@$(MAKE) "$(PACK)" DESTDIR="$(DESTDIR_REAL)"

$(PACKS):
	$(MAKE) pub DESTDIR="$(DESTDIR_REAL)" -C src/$@

clean:
	@if [ -n "$(PACK)" ]; then \
	  $(MAKE) clean-pack PACK="$(PACK)" DESTDIR="$(DESTDIR_REAL)"; \
	else \
	  for pack in $(PACKS); do \
	    $(MAKE) clean DESTDIR="$(DESTDIR_REAL)" -C src/$$pack; \
	    rm -f "$(DESTDIR_REAL)/$$pack.pdf"; \
	  done; \
	fi

clean-pack:
	@if [ -z "$(PACK)" ]; then \
	  echo "PACK is required. Use 'make clean PACK=<pack>'."; \
	  exit 1; \
	fi
	@$(MAKE) clean DESTDIR="$(DESTDIR_REAL)" -C src/$(PACK)
	@rm -f "$(DESTDIR_REAL)/$(PACK).pdf"
