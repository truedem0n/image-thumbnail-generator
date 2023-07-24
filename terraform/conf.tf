module "templates" {
    source = "../../templates"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "terraform-backend-440546640008"
    key    = "aws_stuff/projects/thumbnail-processing/terraform"
    region = "us-east-1"
    profile = "AdministratorAccess-440546640008"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "AdministratorAccess-440546640008"
}

output  key {
  value = join("/", slice(split("/", path.cwd), index(split("/", path.cwd), "aws_stuff"), length(split("/", path.cwd))))
}