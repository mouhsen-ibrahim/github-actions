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

ARG ARM_CLIENT_ID
ARG ARM_TENANT_ID
ARG ARM_SUBSCRIPTION_ID
ARG ARM_USE_OIDC
ARG ACTIONS_ID_TOKEN_REQUEST_URL
ARG ACTIONS_ID_TOKEN_REQUEST_TOKEN

RUN sh -c "\
    mkdir /out && \
    terraform init -input=false && \
    terraform validate && \
    terraform plan -input=false -out=/out/plan.out && \
    echo '\n--- Plan saved to plan.out ---\n' && \
    terraform show -no-color /out/plan.out && \
    cp -r .terraform /out/ && \
    cp .terraform.lock.hcl /out/ \
    "

FROM scratch AS export
COPY --from=plan /out/ /
