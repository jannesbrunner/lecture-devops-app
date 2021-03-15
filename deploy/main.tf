terraform {
  backend "s3" {
    bucket         = "lecture-devops-app-jb-tfstate"
    key            = "devops-app.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lecture-devops-app-tfstate-lock"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 2.54.0"
}

# dynamic variables in tf are locals
locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  # These common tags will be displayed in AWS etc.
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}

# to receive current aws region:
data "aws_region" "current" {}
