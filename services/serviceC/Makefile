include ../../Makefile.variables
GOOGLE_APPLICATION_CREDENTIALS ?= ${HOME}/.config/gcloud/application_default_credentials.json
VERSION    					   ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
TF_VERSION    				   ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
ENV                            ?= dev
build:
	@echo "Building serviceC"
	@mkdir -p ./terraform-plan
	docker buildx build --env=TF_VAR_project_id=${GCP_PROJECT_ID} --build-context ext=${HOME}/.azure --secret id=gcloud_config,src=${GOOGLE_APPLICATION_CREDENTIALS} --target=export --output type=local,dest=./terraform-plan --build-arg VERSION=$(TF_VERSION) --build-arg action=plan --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}

init:
	@mkdir -p ./terraform-plan
	docker buildx build --env=TF_VAR_project_id=${GCP_PROJECT_ID} --build-context ext=${HOME}/.azure --secret id=gcloud_config,src=${GOOGLE_APPLICATION_CREDENTIALS} --target=export --output type=local,dest=./terraform-plan --build-arg VERSION=$(TF_VERSION) --build-arg action=init --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}
	cp ./terraform-plan/.terraform.lock.hcl .

publish:
	@echo "Publishing serviceC"

run:
	@echo "Running serviceC"

test:
	@echo "Testing serviceC"

clean:
	@echo "Cleaning serviceC"

deploy:
	@echo "Deploying serviceC in env ${ENV}"
	mkdir -p ./terraform-plan
	docker buildx build --env=TF_VAR_project_id=${GCP_PROJECT_ID} --build-context ext=${HOME}/.azure --secret id=gcloud_config,src=${GOOGLE_APPLICATION_CREDENTIALS} --build-arg VERSION=$(TF_VERSION) --build-arg action=apply --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}
