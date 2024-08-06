provider "aws" {
  region = var.region
  # profile = "default"

  default_tags {
    tags = {
      "Automation"  = "Terraform"
      "Project"     = var.project_name
      "Environment" = var.environment
    }
  }
}

terraform {
  required_version = ">= 1.0"


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}