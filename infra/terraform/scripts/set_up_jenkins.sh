#!/bin/bash
terraform -chdir="../" init
terraform -chdir="../" plan
terraform -chdir="../" apply -target="module.s3" -auto-approve

chmod +x ./upload_volume_s3.sh
./upload_volume_s3.sh

terraform -chdir="../" apply -target="module.networking" -target="module.s3" -target="module.jenkins" -auto-approve

