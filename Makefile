WDIR := $(shell pwd)
IMAGE_NAME = dotfile-linter

default: run

PHONY := image
image:
	docker build -t $(IMAGE_NAME) .

PHONY += run
run: image
	docker run --rm --volume $(WDIR):/code:ro $(IMAGE_NAME)

PHONY += clean
clean:
	docker rmi $(IMAGE_NAME):latest || true

PHONY += distclean
distclean: clean
	docker rmi debian:bookworm-slim

.PHONY = $(PHONY)
