provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-softserve"
    key    = "terraform.tfstate"
    dynamodb_table = "terraform-backend"
    region = "us-east-1"
  }
}


/* 
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-backend"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
} */