include ../../Makefile.variables
build:
	@echo "Building serviceC"
	docker buildx build --build-context ext=${HOME}/.azure --target=export --output type=local,dest=./terraform-plan --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}

publish:
	@echo "Publishing serviceC"

run:
	@echo "Running serviceC"

test:
	@echo "Testing serviceC"

clean:
	@echo "Cleaning serviceC"

deploy:
	@echo "Deploying serviceC"
	docker run --rm -v ${PWD}/terraform-plan:/terraform -w /terraform hashicorp/terraform:1.13.1 apply -auto-approve /terraform/plan.out
