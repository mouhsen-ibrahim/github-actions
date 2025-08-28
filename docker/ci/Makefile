include ../../Makefile.variables

GIT_SHA    := $(shell git rev-parse --short=12 HEAD)
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

build:
	docker build --build-arg VCS_REF=$(GIT_SHA) --build-arg BUILD_DATE=$(BUILD_DATE) -t ${DOCKER_REGISTRY}/ci:latest .
	docker push ${DOCKER_REGISTRY}/ci:latest

test:
	echo "no tests"
