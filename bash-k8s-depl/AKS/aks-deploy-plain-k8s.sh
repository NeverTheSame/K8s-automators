#!/bin/bash
source ../../utility.sh
check_az_cli_installed

set_az_subscription

read_initials() {
  # Define initials and create resource group
  printf "Enter your initials (e.g. aa) or name for RG and AKS names consistency: "
  read initials
}
read_initials

create_res_group() {
  AKS_RESOURCE_GROUP="azure-$initials-rg"
  LOCATION="westus"
  printf "Creating $AKS_RESOURCE_GROUP resource group ...\n"
  az group create --location $LOCATION \
    --resource-group $AKS_RESOURCE_GROUP \
    -o none
  write_to_secret "AKS_RESOURCE_GROUP azure-$initials-rg"
}
create_res_group

AKS_NAME="aks-$initials"

AKS_EXISTS=0
check_aks_exists() {
  printf "Checking if AKS $AKS_NAME exists ...\n"
  az aks show --resource-group $AKS_RESOURCE_GROUP \
    --name $AKS_NAME &>/dev/null
}
check_aks_exists
if [[ $? -ne 0 ]]; then
  echo "Setting AKS_EXISTS to 0"
  AKS_EXISTS=0
fi

create_AKS_cluster_with_system_node_pool() {
  write_to_secret "AKS_NAME aks-$initials"
  printf "Creating $AKS_NAME AKS ..\n"
  az aks create --resource-group $AKS_RESOURCE_GROUP \
                --node-count 1 \
                --enable-cluster-autoscaler \
                --min-count 1 \
                --max-count 3 \
                --network-plugin azure \
                --node-vm-size Standard_DS2_v2 \
                --nodepool-name system1 \
                --enable-ahub \
                --name $AKS_NAME \
                -o none
}

if [[ $AKS_EXISTS -eq 1 ]]; then
  printf "AKS $AKS_NAME already exists. Not creating a new one.\n"
else
  echo "Creating AKS"
  create_AKS_cluster_with_system_node_pool
fi


# create_AKS_cluster_with_system_node_pool

ask_removal_of_aks_and_rg() {
  printf "Do you want to remove AKS $AKS_NAME and $RESOURCE_GROUP? (y/n) "
  read remove_aks
  if [ "$remove_aks" == "y" ]; then
    printf "Removing AKS $AKS_NAME ..."
    az aks delete --resource-group $AKS_RESOURCE_GROUP \
      --name $AKS_NAME \
      --output none
    printf "Removing RG $AKS_RESOURCE_GROUP ..."
    az group delete --name $AKS_RESOURCE_GROUP \
      --output none
    printf "AKS $AKS_NAME and RG $AKS_RESOURCE_GROUP removed."
  fi
}

connect_local_machine_to_cluster() {
  # connect the cluster to local client machine
  printf "Connecting to AKS $AKS_NAME...\n"
  az aks get-credentials --name $AKS_NAME \
    --resource-group $AKS_RESOURCE_GROUP \
    --overwrite-existing \
    -o none
  if [[ $? -eq 0 ]]; then
    printf "Connected to AKS $AKS_NAME.\n"
  else
    printf "Could not connect to AKS $AKS_NAME.\n"
    exit 1
  fi
}
connect_local_machine_to_cluster
