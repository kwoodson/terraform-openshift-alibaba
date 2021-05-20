#!/bin/bash
export PATH=$PATH:$(pwd)/bin/

if [ $(find ~/alibaba/build/cluster/master.ign -mmin +240)  ];
then
 pushd ~/alibaba/build/
   ./cluster.sh
 popd
fi

terraform fmt -recursive
terraform init

#export TF_LOG=TRACE
#export TF_LOG_PATH=/home/kwoodson/alibaba/tf/tf_debug.log
terraform apply -auto-approve -var-file ./secrets/terraform.tfvars

# terraform destroy
# remove statefile
#terraform destroy -auto-approve -var-file ./secrets/terraform.tfvars 

scp ../oc root@$(aliyun ecs DescribeInstances --RegionId us-east-1 --InstanceName bastion | jq  -r '.Instances.Instance[0].PublicIpAddress.IpAddress[0]'):
scp ../build/cluster/auth/kubeconfig root@$(aliyun ecs DescribeInstances --RegionId us-east-1 --InstanceName bastion | jq  -r '.Instances.Instance[0].PublicIpAddress.IpAddress[0]'):

ssh root@$(aliyun ecs DescribeInstances --RegionId us-east-1 --InstanceName bastion | jq  -r '.Instances.Instance[0].PublicIpAddress.IpAddress[0]')       
#oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}
