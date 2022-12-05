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


/* backend "s3" {
    bucket         = "pokedex-global-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "pokedex-global-terraform-locks"
    encrypt        = true
  }

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project}-${var.environment}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
} */