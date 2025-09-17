include ../../Makefile.variables
build:
	@echo "Building serviceC"
	#terraform init
	#terraform plan -input=false
	docker buildx build --build-context ext=${HOME}/.azure --build-context gcloud=${GOOGLE_APPLICATION_CREDENTIALS} --target=export --output type=local,dest=./terraform-plan --build-arg service=services/serviceC -f ${ROOT}/terraform.Dockerfile ${ROOT}

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
	docker buildx build --build-context ext=${HOME}/.azure --build-arg service=services/serviceC -f ${ROOT}/terraform.apply.Dockerfile ${ROOT}
