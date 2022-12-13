AWS_S3_BUCKET="artifacts-demo-bucket"
ARTIFACT_NAME="$1/docker-compose.yml"
REGION="us-east-1"
FILE_PATH="../docker-compose/$1/docker-compose.yml"

aws configure set region $REGION
aws s3 cp $FILE_PATH s3://$AWS_S3_BUCKET/$ARTIFACT_NAME