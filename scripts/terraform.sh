#!/bin/sh
set -eo
action="$1"

mkdir -p /tmp/azcfg && cp -a /azcfg/* /tmp/azcfg/
export AZURE_CONFIG_DIR=/tmp/azcfg
mkdir /out
export GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcloud_config
if [ "${action}" = "plan" ]; then
    terraform init -lockfile=readonly -input=false
    terraform validate
    terraform plan -input=false -out=/out/plan.out
    echo '\n--- Plan saved to plan.out ---\n'
    terraform show -no-color /out/plan.out;
elif [ "${action}" = "init" ]; then
    terraform init -input=false
elif [ "${action}" = "apply" ]; then
    terraform init -lockfile=readonly -input=false
    terraform apply -input=false -auto-approve /terraform/plan.out
    echo '\n--- Apply completed ---\n';
else \
    echo "Unsupported action: ${action}" && exit 1;
fi;
cp -r .terraform /out/
cp .terraform.lock.hcl /out/