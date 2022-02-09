terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "my_organization"

    workspaces {
      name = "my_workspace"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "us-east-1" {
  source = "./aws"
}