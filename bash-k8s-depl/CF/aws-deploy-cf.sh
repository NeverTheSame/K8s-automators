#!/bin/bash
source ../../utility.sh

check_aws_cli_installed
read_initials

AWS_REGION="us-west-2"
write_to_secret "AWS_REGION us-west-2"

CF_CREATION_STATUS_CODE=1
create_cf_stack() {
    # Create an Cloudformation stack with public and private subnets
    echo "Checking if stack exists ..."
    if ! aws cloudformation describe-stacks --region $AWS_REGION --stack-name $initials-cf-stack &>/dev/null; then
        echo -e "\nStack does not exist, creating ..."
        # fetch the CF template name from manifet's secret
        CF_TEMPLATE_BODY=$(read_from_secret "CF_FILE_AWS" "../manifest/secret")
        aws cloudformation create-stack \
        --region $AWS_REGION \
        --stack-name $initials-cf-stack \
        --template-body file://$CF_TEMPLATE_BODY \
        --parameters \
        ParameterKey=TargetRegions,ParameterValue="us-west-2 us-east-2" \
        ParameterKey=AvailabilityZone,ParameterValue="us-west-2a" \
        --capabilities CAPABILITY_NAMED_IAM &>/dev/null
        CF_CREATION_STATUS_CODE=$?
        if [[ $CF_CREATION_STATUS_CODE -eq 0 ]]; then
            write_to_secret "CF $initials-cf-stack"
        fi
        echo "$initials-cf-stack created"
    else
        echo -e "Stack exists."
    fi
    
}
create_cf_stack

cf_creation_status() {
    # Check if CF stack was created
    # Assuming 2 outputs: CREATE_IN_PROGRESS and CREATE_COMPLETE
    aws cloudformation describe-stacks --region $AWS_REGION --stack-name $initials-cf-stack --query "Stacks[].StackStatus" --output text
}

ping_cf_creation() {
    # Check CF_CREATION_STATUS_CODE in a loop
    while true; do
        echo " $(date): Checking CF cluster status ..."
        if [[ $(cf_creation_status) == "CREATE_COMPLETE" ]]; then
            echo -e "\n\e[1;42m CF stack is active \e[0m\n"
            break
        else
            echo -e "\e[1;31m CF stack is not active yet ... \e[0m"
            sleep 30
        fi
    done
}
if [[ $CF_CREATION_STATUS_CODE == "0" ]]
then
    ping_cf_creation
fi
