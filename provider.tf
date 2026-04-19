terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "matte-resilient-aws-infra-tfstate-2027"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "matte-resilient-aws-infra-locks-2027"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}