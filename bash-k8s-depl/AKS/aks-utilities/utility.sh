
create_user_managed_identity() {
  # In order for AKS to securely manage and provision your clusters 
  # you should be owner or administrator of the subscription under which
  # you are creating your AKS cluster.
  AKS_IDENTITY="identity-$initials"
  AKS_IDENTITY_ID=$(az identity create \
  --name $AKS_IDENTITY \
  --resource-group $AKS_RESOURCE_GROUP \
  --query id \
  -o tsv)
  write_to_secret "AKS_IDENTITY identity-$initials"
}

create_virtual_network_and_subnet() {
  # Create a Virtual Network and a Subnet
  AKS_VNET="aks-$initials-vnet"
  AKS_VNET_SUBNET="aks-$initials-subnet"
  AKS_VNET_ADDRESS_PREFIX="10.0.0.0/8"
  AKS_VNET_SUBNET_PREFIX="10.240.0.0/16"

  az network vnet create --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_VNET" \
  --address-prefix $AKS_VNET_ADDRESS_PREFIX \
  --subnet-name "$AKS_VNET_SUBNET" \
  --subnet-prefix $AKS_VNET_SUBNET_PREFIX \
  -o none
  write_to_secret "AKS_VNET $AKS_VNET"
}

get_virtual_network_default_subnet_id () {
  AKS_VNET_SUBNET_ID=$(az network vnet subnet show \
  --resource-group $AKS_RESOURCE_GROUP \
  --vnet-name $AKS_VNET \
  --name $AKS_VNET_SUBNET --query id -o tsv)
  write_to_secret "Subnet $AKS_VNET_SUBNET_ID"
}

create_law() {
  # Create a Log Analytics Workspace 
  LOG_ANALYTICS_WORKSPACE_NAME="aks-$initials-law"
  LOG_ANALYTICS_WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace create \
  --resource-group $AKS_RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
  --query id -o tsv)
  write_to_secret "LAW_ID $LOG_ANALYTICS_WORKSPACE_RESOURCE_ID"
}

create_simple_AKS_cluster () {
  AKS_NAME="aks-$initials"
  write_to_secret "AKS_NAME aks-$initials"
  printf "\nCreating $AKS_NAME AKS ..\n"
  az aks create --node-count 2 \
    --generate-ssh-keys \
    --name $AKS_NAME \
    --resource-group $AKS_RESOURCE_GROUP \
    -o none
}

create_linux_user_node_pool() {
  az aks nodepool add --resource-group $AKS_RESOURCE_GROUP \
  --cluster-name $AKS_NAME \
  --os-type Linux \
  --name linux1 \
  --node-count 1 \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 3 \
  --mode User \
  --node-vm-size Standard_DS2_v2 \
  -o none
}

create_windows_user_node_pool() {
  az aks nodepool add --resource-group $AKS_RESOURCE_GROUP \
                      --cluster-name $AKS_NAME \
                      --os-type Windows \
                      --name win1 \
                      --node-count 1 \
                      --mode User \
                      --node-vm-size Standard_DS2_v2 \ 
                      -o none
}