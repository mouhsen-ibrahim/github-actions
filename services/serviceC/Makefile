include ../../Makefile.variables
build:
	@echo "Building serviceC"
	docker buildx build --target=export --output type=local,dest=./terraform-plan --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}

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
