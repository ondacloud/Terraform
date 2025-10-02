terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.1.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }

    archive = {
      source = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "default"
}

provider "tls" {}

provider "local" {}

provider "archive" {}

data "aws_caller_identity" "caller" {}

data "aws_availability_zones" "az" {
  state = "available"
}