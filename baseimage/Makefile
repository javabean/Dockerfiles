NAME = cedrik/baseimage
VERSION = 0.9.19.1

.PHONY: all build test tag_latest release ssh

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm image

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

