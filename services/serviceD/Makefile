include ../../Makefile.variables
VERSION    ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
VCS_REF    := $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
build:
	@echo "Building serviceD"
	@docker build --build-arg service=services/serviceD --build-arg VERSION=$(VERSION) --build-arg VCS_REF=$(VCS_REF) --build-arg BUILD_DATE=$(BUILD_DATE) -t ${DOCKER_REGISTRY}/serviced:${VERSION} -f ${ROOT}/python.Dockerfile ${ROOT}
	@docker save ${DOCKER_REGISTRY}/serviced:${VERSION} -o docker.serviced.tar

publish:
	@echo "Publishing serviceD"
	@docker load -i docker.serviced.tar/docker.serviced.tar
	@docker push ${DOCKER_REGISTRY}/serviced:${VERSION}

run:
	@echo "Running serviceD"

test:
	@echo "Testing serviceD"

clean:
	@echo "Cleaning serviceD"

deploy:
	@echo "Deploying serviceD"
