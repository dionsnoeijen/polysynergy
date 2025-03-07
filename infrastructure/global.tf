terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "polysynergy-terraform-state"
    key          = "state/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "eu-central-1"
}