#!/bin/bash
export PATH=$PATH:$(pwd)/bin/

# pushd ~/alibaba/build/
#   ./cluster.sh
# popd

terraform fmt -recursive
terraform init

#export TF_LOG=TRACE
#export TF_LOG_PATH=/home/kwoodson/alibaba/tf/tf_debug.log
terraform apply -auto-approve -var-file ./secrets/terraform.tfvars

# terraform destroy
# remove statefile
#terraform destroy -auto-approve -var-file ./secrets/terraform.tfvars 