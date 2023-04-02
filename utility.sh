#!/bin/bash
# Define utility functions

read_from_secret() { 
  if [ $# -eq 0 ]
  then
  echo 'No arguments supplied'
  exit
  elif [ $# -eq 1 ]
  then
  SECRET_FILE=secret
  elif [ $# -eq 2 ]
  then
  SECRET_FILE=$2
  fi

  cat $SECRET_FILE | while read line; do
  key=$(echo $line | cut -d ' ' -f1)
  value=$(echo $line | cut -d ' ' -f2)
  if [[ $key == $1 ]]; then
      echo $value
  fi
  done
}

write_to_secret() {
  search_string=$(grep "$1" secret | cut -d ' ' -f1)
  if [[ -z "$search_string" ]]; then
    echo "$1" >>secret
    echo "wrote $1 to secret"
  else
    echo -e "\e[1;43m$search_string is already in secret \e[0m"
  fi
}

check_aws_cli_installed() {
  # Confirm AWS CLI
  if ! command -v aws &>/dev/null; then
    echo "aws could not be found. Installing ..."
    brew update && brew install awscli
    echo "aws was installed. Run script again."
    exit
  fi
}

check_az_cli_installed() {
  # check az cli exists
  if ! command -v az &>/dev/null; then
    echo "az could not be found. Installing ..."
    brew update && brew install azure-cli
    echo "az was installed. Run script again."
    exit
  fi
}

read_initials() {
  # Define initials for name consistency
  printf "\nEnter your initials (e.g. kk) or name for name consistency: "
  read initials
}

check_kubectl_installed() {
  # Confirm kubectl
  if ! command -v kubectl &>/dev/null; then
    echo "kubectl could not be found. Installing ..."
    brew update && brew install kubectl
    echo "kubectl was installed. Run script again."
    exit
  fi
}

apply_k8s_files() {
  if [[ -z "$1" ]]; then
    echo "No manifest file provided. Exiting."
    exit
  fi

  FILE_NAME=$1
  # check if file name is for AZ or AWS
  if [[ "$1" == "az" ]]; then
    FILE_NAME=$(read_from_secret "K8S_MANIFEST_FILE" "../manifest/secret")
  elif [[ "$1" == "aws" ]]; then
    FILE_NAME="manifest-aws.1iq"
  else  
    echo "Manifest file name is not recognized. Exiting."
    exit
  fi

  if ! kubectl apply -f "../manifest/$FILE_NAME"; then
    echo -e "\e[1;31m Unable to connect to the k8s cluster \e[0m" 
    exit
  fi

  # kubectl apply -f "K8/init-container-pattern"
  kubectl apply -f "../K8/sample-dep.yaml"
  kubectl apply -f "../K8/sample-svc.yaml"
  
}

set_az_subscription () {
  if [[ "$1" == "from_secret" ]]
  then
    echo "Reading subsription from secret"
    # second argument $2 is the subsription name
    SUBSCRIPTION=$(read_from_secret "$2")
    SUBSCRIPTION_NAME=$(az account show --subscription $SUBSCRIPTION --query "{name:name}" --output tsv)
    printf "Setting subscription to: %s\n" "$SUBSCRIPTION_NAME"
    az account set -s "$SUBSCRIPTION" -o none
  else
      printf "List of subscriptions listed below\n"
    az account list -o table --query '[].{name: name, isDefault: isDefault}'
    default_subscription=$(az account list \
      --query "[?isDefault].name" --output tsv)
    printf "\nType subscription name (Type '0' to use default subscription): "
    read -r subscription_name

    if [[ $subscription_name == '0' ]]; then
      echo "Proceeding with the default subscription: $default_subscription"
      subscription_name=$default_subscription
    fi
    az account set --subscription "$subscription_name" -o none
  fi
}

erase_secret() {
  # erase content of secret file
  echo "Erasing content of secret ... "
  echo -n "" > secret
}