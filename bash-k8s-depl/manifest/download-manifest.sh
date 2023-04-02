#!/bin/bash
source ../../utility.sh

set_az_subscription from_secret SUBS_NAME_L

DATE=($(date +'%m-%d-%y'))

# get deity token dev
VAULT_NAME=$(read_from_secret "VAULT_NAME")
TOKEN_NAME=$(read_from_secret "NEXT_TOKEN_NAME")
TOKEN=$(az keyvault secret show --vault-name $VAULT_NAME --name $TOKEN_NAME --query 'value' -o tsv)

ENVIRONMENT=$(read_from_secret "ENVIRONMENT")
PORTAL_URL=$(read_from_secret "NEXT_PORTAL_URL")
NAMESPACE=$(read_from_secret "NAMESPACE")

download_k8s_manifest() {
    # download manifest for AKS/EKS from ITE
    MANIFEST_FILE=$(read_from_secret "MANIFEST_FILE")
    K8S_ENDPOINT=$(read_from_secret "K8S_ENDPOINT")
    curl --location --request GET "https://$PORTAL_URL/environments/$ENVIRONMENT/manifest/pulse/$K8S_ENDPOINT/linux-x64?&deploymentName=depl-$DATE&k8sNamespace=$NAMESPACE" \
    --header "Authorization: Bearer $TOKEN" \
    --output "$DATE-$MANIFEST_FILE" 2>/dev/null
    write_to_secret "K8S_MANIFEST_FILE $DATE-$MANIFEST_FILE"
    printf "Downloaded $DATE-$MANIFEST_FILE from $ENVIRONMENT\n"
}
download_k8s_manifest

download_aws_cf_template() {
    # download AWS CF file
    AWS_CF_PROVIDER_ENDPOINT=$(read_from_secret "AWS_CF_PROVIDER_ENDPOINT")
    curl --location --request GET "https://$PORTAL_URL/environments/$ENVIRONMENT/manifest/pulse/$AWS_CF_PROVIDER_ENDPOINT/linux-x64?&deploymentName=aws-depl-$DATE&k8sNamespace=$NAMESPACE" \
    --header "Authorization: Bearer $TOKEN" \
    --output "../CF/$DATE-cf-template.yaml" 2>/dev/null
    write_to_secret "CF_FILE_AWS $DATE-cf-template.yaml"
    printf "Downloaded $DATE-cf-template.yaml template from $ENVIRONMENT to CF directory\n"
}
