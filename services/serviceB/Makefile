include ../../Makefile.variables
build:
	@echo "Building serviceB"
	docker build --build-arg service=services/serviceB -t ${DOCKER_REGISTRY}/serviceb:latest -f ${ROOT}/node.Dockerfile ${ROOT}
	docker push ${DOCKER_REGISTRY}/serviceb:latest

run:
	@echo "Running serviceB"

test:
	@echo "Testing serviceB"

clean:
	@echo "Cleaning serviceB"

deploy:
	@echo "Deploying serviceB"

publish:
	@echo "Publishing serviceB"
