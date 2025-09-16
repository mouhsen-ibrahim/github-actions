include ../../Makefile.variables
build:
	@echo "Building serviceC"
	echo ${ARM_SUBSCRIPTION_ID}
	terraform init -input=false
	docker buildx build --target=export -e ARM_CLIENT_ID -e ARM_TENANT_ID -e ARM_SUBSCRIPTION_ID -e ARM_USE_OIDC -e ACTIONS_ID_TOKEN_REQUEST_URL -e ACTIONS_ID_TOKEN_REQUEST_TOKEN --output type=local,dest=./terraform-plan --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}

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
