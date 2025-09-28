include ../../Makefile.variables
VERSION    ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
VCS_REF    := $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

publish:
	@docker build --build-arg VERSION=$(VERSION) --build-arg VCS_REF=$(VCS_REF) --build-arg BUILD_DATE=$(BUILD_DATE) -t ${DOCKER_REGISTRY}/ci-terraform:${VERSION} -f Dockerfile .
	@docker push ${DOCKER_REGISTRY}/ci-terraform:${VERSION}

commit:
	@echo ${VERSION}