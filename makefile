.PHONY: all

all: murdocker
murdocker: Dockerfile
	docker build -t murdocker .