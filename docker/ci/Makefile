include ../../Makefile.variables
VCS_REF=$(git rev-parse HEAD)
BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

build:
	docker build --build-arg VCS_REF=${VCS_REF} --build-arg BUILD_DATE=${BUILD_DATE} -t ${REPO_URL}/ci:latest .
	docker push ${REPO_URL}/ci:latest

test:
	echo "no tests"
