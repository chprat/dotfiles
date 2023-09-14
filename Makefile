WDIR := $(shell pwd)
IMAGE_NAME = dotfile-linter

default: run

PHONY := image
image:
	podman build -t $(IMAGE_NAME) .

PHONY += run
run: image
	podman run --rm --volume $(WDIR):/code:ro $(IMAGE_NAME)

PHONY += clean
clean:
	podman rmi $(IMAGE_NAME):latest || true

PHONY += distclean
distclean: clean
	podman rmi debian:bookworm-slim

.PHONY = $(PHONY)
