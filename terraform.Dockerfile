FROM hashicorp/terraform:1.13.1 AS plan

WORKDIR /workspace
ARG service
COPY ${service} /workspace

RUN sh -c "\
    mkdir /out && \
    terraform init -input=false && \
    terraform validate && \
    terraform plan -input=false -out=/out/plan.out && \
    echo '\n--- Plan saved to plan.out ---\n' && \
    terraform show -no-color /out/plan.out \
    cp -r .terraform /out/ \
    cp .terraform.lock.hcl /out/ \
    "

FROM scratch AS export
COPY --from=plan /out/ /
