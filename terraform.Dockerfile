ARG VERSION=latest
FROM ghcr.io/mouhsen-ibrahim/github-actions/ci-terraform:${VERSION} AS plan

WORKDIR /workspace
ARG service
COPY ${service} /workspace
ARG action=plan

COPY ./scripts/terraform.sh .
RUN --mount=type=bind,source=${service}/terraform-plan,target=/terraform,readonly --mount=type=bind,from=ext,source=.,target=/azcfg,readonly --mount=type=secret,id=gcloud_config ls && ./terraform.sh ${action}

FROM scratch AS export
COPY --from=plan /out/ /
