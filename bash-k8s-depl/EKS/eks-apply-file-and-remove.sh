#!/bin/zsh -x
source ../../utility.sh
check_kubectl_installed
# apply_k8s_files "aws"
EKS_CLUSTER_ARN=$(read_from_secret "EKS_CLUSTER_ARN") 
kubectl config use-context $EKS_CLUSTER_ARN
kubectl apply -f "../manifest/$(read_from_secret "K8S_MANIFEST_FILE" "../manifest/secret")"



printf "\nWaiting for 10 minutes and removing $EKS_NAME ..."
sleep 600

EKS_NAME=$(read_from_secret "EKS")
AWS_REGION=$(read_from_secret "AWS_REGION")
CF=$(read_from_secret "CF")

delete_EKS() {
  aws eks delete-cluster --name $EKS_NAME --region $AWS_REGION &>/dev/null
}

delete_CF() {
  # delete cloudformation stack
    aws cloudformation delete-stack --stack-name $CF &>/dev/null
}

cleanup_EKS_resources() {
  # cleans up all created resources so that exit code can be used with the next command
  delete_EKS
  EKS_DELETE_STATUS_CODE=$?
  if [[ $EKS_DELETE_STATUS_CODE -eq 0 ]]; then
    echo "Removing EKS cluster $EKS_NAME."
  else
    echo "EKS cluster $EKS_NAME could not be deleted."
    break
  fi

  delete_CF
  CF_DELETE_STATUS_CODE=$?
  if [[ $CF_DELETE_STATUS_CODE -eq 0 ]]; then
    echo "Removing CF stack $CF."
  else
    echo "CF stack $CF could not be deleted."
    break
  fi
}
cleanup_EKS_resources

# erase secret only if EKS resources were deleted successfully
EKS_RESOURCES_REMOVED=$?
if [[ $EKS_RESOURCES_REMOVED -eq 0 ]]; then
  echo "EKS resources removed."
  erase_secret
else
  echo "EKS resources could not be removed."
  exit 1
fi
