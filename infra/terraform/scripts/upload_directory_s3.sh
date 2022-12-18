#!/bin/bash

AWS_S3_BUCKET="artifacts-demo-bucket"
ARTIFACT_NAME="$2"
REGION="us-east-1"
FILE_PATH="$1"

tar -zcvf $ARTIFACT_NAME.tar.gz $FILE_PATH
aws configure set region $REGION
aws s3 cp ./$ARTIFACT_NAME.tar.gz s3://$AWS_S3_BUCKET/$ARTIFACT_NAME.tar.gz