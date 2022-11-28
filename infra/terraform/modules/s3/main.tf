resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = "demo-artf-webapp"
}

# Set the ACL of the S3 bucket to private
resource "aws_s3_bucket_acl" "release_bucket_acl" {
  bucket = aws_s3_bucket.artifacts_bucket.id
  acl = "private"
}