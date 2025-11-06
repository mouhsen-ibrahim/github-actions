include ../../Makefile.variables
VERSION    ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
VCS_REF    := $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
ENV        ?= dev
build:
	@echo "Building serviceB"
	@docker build --build-arg service=services/serviceB --build-arg VERSION=$(VERSION) --build-arg VCS_REF=$(VCS_REF) --build-arg BUILD_DATE=$(BUILD_DATE) -t ${DOCKER_REGISTRY}/serviceb:${VERSION} -f ${ROOT}/node.Dockerfile ${ROOT}
	@docker save ${DOCKER_REGISTRY}/serviceb:${VERSION} -o docker.serviceb.tar

publish:
	@echo "Publishing serviceB"
	@docker load -i docker.serviceb.tar/docker.serviceb.tar
	@docker push ${DOCKER_REGISTRY}/serviceb:${VERSION}

run:
	@echo "Running serviceB"

test:
	@echo "Testing serviceB"

clean:
	@echo "Cleaning serviceB"

deploy:
	@echo "Deploying serviceB in env ${ENV}"
