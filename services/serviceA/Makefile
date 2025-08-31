include ../../Makefile.variables
VERSION    ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
VCS_REF    := $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
build:
	@echo "Building serviceA"
	@docker build --build-arg service=services/serviceA --build-arg VERSION=$(VERSION) --build-arg VCS_REF=$(VCS_REF) --build-arg BUILD_DATE=$(BUILD_DATE) -t ${DOCKER_REGISTRY}/servicea:latest -f ${ROOT}/go.Dockerfile ${ROOT}
	@docker save ${DOCKER_REGISTRY}/servicea:latest -o docker.servicea.tar

publish:
	@echo "Publishing serviceA"
	@docker load -i docker.servicea.tar/docker.servicea.tar
	@docker push ${DOCKER_REGISTRY}/servicea:latest

run:
	@echo "Running serviceA"

test:
	@echo "Testing serviceA"

clean:
	@echo "Cleaning serviceA"

deploy:
	@echo "Deploying serviceA"
