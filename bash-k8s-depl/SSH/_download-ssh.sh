#!/bin/bash
source ../../utility.sh

# change subsription, global var must be in .bash_profile
source ~/.bash_profile
printf "Setting subsription to: $SUBS_NAME\n"
az account set -s "$SUBS_NAME" -o none

VAULT_NAME=$(read_from_secret "VAULT_NAME")
TOKEN_NAME=$(read_from_secret "TOKEN_NAME")

# get deity token dev
export TOKEN=$(az keyvault secret show --vault-name $VAULT_NAME --name $TOKEN_NAME --query 'value' -o tsv)
export SSH_KEY="secure.pem"

API_ENDPOINT=$(read_from_secret "API_ENDPOINT")

# download key
printf "\nDownloading ssh key: $SSH_KEY\n"
curl --location --request GET '$API_ENDPOINT' \
--header "Authorization: Bearer $TOKEN" \
--output $MANIFEST_FILE 2>/dev/null
