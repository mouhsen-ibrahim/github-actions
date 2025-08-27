include ../../Makefile.variables
build:
	@echo "Building serviceD"
	docker build -t ${DOCKER_REGISTRY}/serviced:latest -f ${ROOT}/python.Dockerfile .
	docker push ${DOCKER_REGISTRY}/serviced:latest

run:
	@echo "Running serviceD"

test:
	@echo "Testing serviceD"

clean:
	@echo "Cleaning serviceD"

deploy:
	@echo "Deploying serviceD"

publish:
	@echo "Publishing serviceD"
