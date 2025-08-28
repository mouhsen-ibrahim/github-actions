include ../../Makefile.variables
build:
	@echo "Building serviceC"
	docker build --target=export --output type=local,dest=./terraform-plan --build-arg service=services/serviceC -t ${DOCKER_REGISTRY}/servicec:latest -f ${ROOT}/terraform.Dockerfile ${ROOT}
	docker push ${DOCKER_REGISTRY}/servicec:latest

run:
	@echo "Running serviceC"

test:
	@echo "Testing serviceC"

clean:
	@echo "Cleaning serviceC"

deploy:
	@echo "Deploying serviceC"

publish:
	@echo "Publishing serviceC"
