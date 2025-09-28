ARG VERSION=latest
FROM ghcr.io/mouhsen-ibrahim/github-actions/ci-terraform:${VERSION} AS plan

WORKDIR /workspace
ARG service
COPY ${service} /workspace
ARG action=plan

RUN --mount=type=bind,from=ext,source=.,target=/azcfg,readonly --mount=type=secret,id=gcloud_config sh -c "\
    mkdir -p /tmp/azcfg && cp -a /azcfg/* /tmp/azcfg/ && \
    export AZURE_CONFIG_DIR=/tmp/azcfg && \
    mkdir /out && \
    export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcloud_config && \
    terraform init -lockfile=readonly -input=false && \
    terraform validate && \
    if [ \"${action}\" = \"plan\" ]; then
        terraform plan -input=false -out=/out/plan.out && \
        echo '\n--- Plan saved to plan.out ---\n' && \
        terraform show -no-color /out/plan.out && \
    else if [ \"${action}\" = \"init\" ]; then
        echo '\n--- no action ---\n' && \
    else if [ \"${action}\" = \"apply\" ]; then
        terraform apply -input=false -auto-approve /terraform/plan.out && \
        echo '\n--- Apply completed ---\n' && \
    else
        echo "Unsupported action: ${action}" && exit 1
    fi && \
    cp -r .terraform /out/ && \
    cp .terraform.lock.hcl /out/ \
    "

FROM scratch AS export
COPY --from=plan /out/ /
