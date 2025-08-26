FROM ubuntu:24.04
RUN apt update && apt install -y make

ARG VCS_REF
ARG BUILD_DATE

# OCI annotations
LABEL org.opencontainers.image.title=ci \
    org.opencontainers.image.version=0.1.0 \
    org.opencontainers.image.description="CI image for building and testing" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/mouhsen-ibrahim/github-actions" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE
