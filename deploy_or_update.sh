#!/bin/bash -x

aws cloudformation describe-stacks --stack-name "tailor-$STAGE_NAME"
if [[ $? -eq 0 ]]; then
    aws cloudformation create-change-set \
        --template-url "https://$S3_BUCKET.s3.amazonaws.com/$STAGE_NAME/config/sam-output.yaml"  \
        --parameters file://cfn-config.json \
        --role-arn "arn:aws:iam::$AWS_ACCOUNT_NUMBER:role/$CFN_ROLE" \
        --change-set-name "tailor-$STAGE_NAME-ChangeSet" \
        --stack-name "tailor-$STAGE_NAME" \
        --capabilities CAPABILITY_IAM
else
    parameters=$(jq -r '.[] | "\(.ParameterKey)=\(.ParameterValue)"' < cfn-config.json | sed ':a;N;$!ba;s/\n/ /g')
    aws cloudformation deploy \
        --template-file sam-output.yaml \
        --stack-name "tailor-$STAGE_NAME" \
        --parameter-overrides $parameters
fi
