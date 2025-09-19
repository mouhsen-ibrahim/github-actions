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

ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.opencontainers.image.title="terraform ci image"
LABEL org.opencontainers.image.description="An image for terraform to be use din CI"
LABEL org.opencontainers.image.source="https://github.com/mouhsen-ibrahim/github-actions"
LABEL org.opencontainers.image.documentation="https://github.com/mouhsen-ibrahim/github-actions#readme"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.licenses="MIT"
