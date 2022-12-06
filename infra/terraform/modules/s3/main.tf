resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "release_bucket_acl" {
  bucket = aws_s3_bucket.artifacts_bucket.id
  acl = "private"
}