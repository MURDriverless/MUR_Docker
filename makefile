.PHONY: all

all: murdocker
murdocker: Dockerfile
	DOCKER_BUILDKIT=1 docker build -t murauto/mur_dev_stack .