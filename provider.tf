terraform {
  required_version = ">= 1.0.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.26.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}
