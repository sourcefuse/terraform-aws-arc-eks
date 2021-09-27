provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  required_providers {
    null = {
      version = "3.1.0"
      source  = "hashicorp/null"
    }
  }
}
