#!/bin/bash
# this script its executed in jenkins server
if [ $1 == "plan" ]; then
    terraform -chdir="infra/terraform/" $1 \
        -target="module.networking" \
        -target="module.s3" \
        -target="module.security_groups" \
        -target="module.compute" \
        -target="module.iam" \
        -target="module.codedeploy" \
        -target="module.app_load_balancer"
else
    terraform -chdir="infra/terraform/" $1 \
        -target="module.networking" \
        -target="module.s3" \
        -target="module.security_groups" \
        -target="module.compute" \
        -target="module.iam" \
        -target="module.codedeploy" \
        -target="module.app_load_balancer" \
        -auto-approve
fi
