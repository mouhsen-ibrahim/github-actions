FROM hashicorp/terraform:1.13.1 AS plan

# Install Azure CLI using pip (Alpine Linux compatible)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    gcc \
    python3-dev \
    musl-dev \
    libffi-dev \
    openssl-dev \
    cargo \
    make \
    pipx

RUN pipx install azure-cli
ENV PATH=/root/.local/bin:${PATH}

WORKDIR /workspace
ARG service
COPY ${service} /workspace

RUN --mount=type=bind,source=${service}/terraform-plan,target=/terraform,readonly --mount=type=bind,from=ext,source=.,target=/azcfg,readonly sh -c "\
    mkdir -p /tmp/azcfg && cp -a /azcfg/* /tmp/azcfg/ && \
    export AZURE_CONFIG_DIR=/tmp/azcfg && \
    terraform init -input=false && \
    terraform apply -input=false -auto-approve /terraform/plan.out \
    "