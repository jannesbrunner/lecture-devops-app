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