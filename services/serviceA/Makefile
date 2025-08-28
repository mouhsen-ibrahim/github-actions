include ../../Makefile.variables
build:
	@echo "Building serviceA"
	docker build --build-arg service=services/serviceA -t ${DOCKER_REGISTRY}/servicea:latest -f ${ROOT}/go.Dockerfile ${ROOT}
	docker push ${DOCKER_REGISTRY}/servicea:latest

run:
	@echo "Running serviceA"

test:
	@echo "Testing serviceA"

clean:
	@echo "Cleaning serviceA"

deploy:
	@echo "Deploying serviceA"

publish:
	@echo "Publishing serviceA"
