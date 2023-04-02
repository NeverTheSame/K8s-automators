#!/bin/bash -x
source ../../utility.sh

check_aws_cli_installed
read_initials

AWS_REGION="us-west-2"
write_to_secret "AWS_REGION us-west-2"

### AWS EKS stack region
EKS_CREATION_STATUS_CODE=1
create_eks() {
  EKS_CLUSTER_NAME="$initials-eks-cluster"
  SECURITY_GROUPS=$(aws cloudformation describe-stacks --stack-name $initials-cf-stack --query 'Stacks[0].Outputs[0].OutputValue')
  SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name $initials-cf-stack --query 'Stacks[0].Outputs[2].OutputValue' --output text)
  ROLE_ARN=$(aws iam get-role \
    --role-name eksrole --query 'Role.Arn' --output text)
  echo "Creating EKS cluster $EKS_CLUSTER_NAME ..."
  aws eks create-cluster \
    --region $AWS_REGION \
    --name $EKS_CLUSTER_NAME \
    --role-arn $ROLE_ARN \
    --resources-vpc-config subnetIds=$SUBNET_IDS,securityGroupIds=$SECURITY_GROUPS &>/dev/null
  # get result of
  EKS_CREATION_STATUS_CODE=$?
  if [[ $EKS_CREATION_STATUS_CODE -eq 0 ]]; then
    write_to_secret "EKS $initials-eks-cluster"
  fi
}
create_eks
eks_creation_status() {
  # Check if EKS cluster was created
  aws eks --region $AWS_REGION describe-cluster --name $EKS_CLUSTER_NAME --query cluster.status --output text
}

ping_eks_creation() {
  # Check eks_creation_status in a loop
  while true; do
    echo " $(date): Checking EKS cluster status ..."
    if [[ $(eks_creation_status) == "ACTIVE" ]]; then
      echo -e "\n\e[1;42m EKS cluster is active \e[0m\n"
      break
    else
      echo -e "\e[1;31m EKS cluster is not active yet ... \e[0m"
      sleep 30
    fi
  done
}
if [[ $EKS_CREATION_STATUS_CODE == "0" ]]
then
  ping_eks_creation
fi

### End of AWS EKS stack region
update_kubeconfig_for_cluster() {
  # connect the cluster to local client machine
  aws eks --region $AWS_REGION update-kubeconfig \
          --name $EKS_CLUSTER_NAME
}
update_kubeconfig_for_cluster
