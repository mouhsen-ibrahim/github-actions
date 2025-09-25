FROM ghcr.io/mouhsen-ibrahim/github-actions/ci-terraform:latest AS plan

WORKDIR /workspace
ARG service
COPY ${service} /workspace

RUN --mount=type=bind,from=ext,source=.,target=/azcfg,readonly --mount=type=secret,id=gcloud_config sh -c "\
    mkdir -p /tmp/azcfg && cp -a /azcfg/* /tmp/azcfg/ && \
    export AZURE_CONFIG_DIR=/tmp/azcfg && \
    mkdir /out && \
    export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcloud_config && \
    terraform init -lockfile=readonly -input=false && \
    terraform validate && \
    terraform plan -input=false -out=/out/plan.out && \
    echo '\n--- Plan saved to plan.out ---\n' && \
    terraform show -no-color /out/plan.out && \
    cp -r .terraform /out/ && \
    cp .terraform.lock.hcl /out/ \
    "

FROM scratch AS export
COPY --from=plan /out/ /
