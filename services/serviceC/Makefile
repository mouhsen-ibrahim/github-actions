include ../../Makefile.variables
build:
	@echo "Building serviceC"
	#docker buildx build --build-context ext=${HOME}/.azure --target=export --build-arg ARM_CLIENT_ID=${ARM_CLIENT_ID} --build-arg ARM_TENANT_ID=${ARM_TENANT_ID} --build-arg ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} --build-arg ARM_USE_OIDC=${ARM_USE_OIDC} --build-arg ACTIONS_ID_TOKEN_REQUEST_URL=${ACTIONS_ID_TOKEN_REQUEST_URL} --build-arg ACTIONS_ID_TOKEN_REQUEST_TOKEN=${ACTIONS_ID_TOKEN_REQUEST_TOKEN} --output type=local,dest=./terraform-plan --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}
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
