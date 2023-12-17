terraform {
  backend "s3" {
    bucket         = "devil-tf-state"
    key            = "terraform/playground/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}




