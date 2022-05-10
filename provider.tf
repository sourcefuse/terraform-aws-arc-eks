terraform {
  required_providers {
    null = {
      version = "3.1.0"
      source  = "hashicorp/null"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
