#!/bin/bash
source ../../utility.sh
check_kubectl_installed
kubectl config use-context $(read_from_secret "AKS_NAME")
kubectl apply -f "../manifest/$(read_from_secret "K8S_MANIFEST_FILE" "../manifest/secret")"

# confirm the connection to the cluster
echo -e "\n\e[0;32m Listing running services ... \e[0m\n"
kubectl get svc

printf "\nWaiting for 10 minutes and removing $AKS_NAME ..."
# sleep 600 

AKS_NAME=$(read_from_secret "AKS_NAME")
AKS_RESOURCE_GROUP=$(read_from_secret "AKS_RESOURCE_GROUP")

delete_AKS() {
  # delete aks cluster
  printf "\nRemoving $AKS_NAME from $AKS_RESOURCE_GROUP\n"
  az aks delete --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP -y
}

delete_RG() {
  # delete resource group
  az group delete --name "$AKS_RESOURCE_GROUP" -y
}

cleanup_AKS_resources() {
  delete_AKS
  AKS_DELETE_STATUS_CODE=$?
  if [[ $AKS_DELETE_STATUS_CODE -eq 0 ]]; then
    echo "Removing AKS cluster $AKS_NAME."
  else
    echo "AKS cluster $AKS_NAME could not be deleted."
    break
  fi

  delete_RG
  RG_DELETE_STATUS_CODE=$?
  if [[ $RG_DELETE_STATUS_CODE -eq 0 ]]; then
    echo "Removing RG $AKS_RESOURCE_GROUP."
  else
    echo "RG cluster $AKS_RESOURCE_GROUP could not be deleted."
    break
  fi
}
cleanup_AKS_resources

# erase secret only if AKS resources were deleted successfully
AKS_RESOURCES_REMOVED=$?
if [[ $AKS_RESOURCES_REMOVED -eq 0 ]]; then
  echo "AKS resources removed."
  # erase_secret
else
  echo "AKS resources could not be removed."
  exit 1
fi
