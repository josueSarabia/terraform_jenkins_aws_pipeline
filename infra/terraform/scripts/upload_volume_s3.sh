#!/bin/bash

AWS_S3_BUCKET="artifacts-demo-bucket"
ARTIFACT_NAME="jenkins-volume"
REGION="us-east-1"
FILE_PATH="../jenkins-volume/"

tar -zcvf $ARTIFACT_NAME.tar.gz $FILE_PATH
aws configure set region $REGION
aws s3 cp ./$ARTIFACT_NAME.tar.gz s3://$AWS_S3_BUCKET/$ARTIFACT_NAME.tar.gz