FROM ghcr.io/mouhsen-ibrahim/github-actions:latest AS plan

WORKDIR /workspace
ARG service
COPY ${service} /workspace

RUN --mount=type=bind,source=${service}/terraform-plan,target=/terraform,readonly --mount=type=bind,from=ext,source=.,target=/azcfg,readonly --mount=type=secret,id=gcloud_config sh -c "\
    mkdir -p /tmp/azcfg && cp -a /azcfg/* /tmp/azcfg/ && \
    export AZURE_CONFIG_DIR=/tmp/azcfg && \
    export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcloud_config && \
    terraform init -input=false && \
    terraform apply -input=false -auto-approve /terraform/plan.out \
    "