## default
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

## network
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"

    values = var.private_subnet_names
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"

    values = var.public_subnet_names
  }
}

// TODO - move this to where it belongs
locals {
  aws_csi_secrets_store_provider_installer_manifest_enabled = var.csi_driver_enabled == true ? 1 : 0

  // TODO - experimental
  kubectl_path_documents_docs = [
    for file in fileset(path.module, "/manifests/*.yaml") : file
  ]
}

// TODO: turn into standard module
// TODO: tighten security
// TODO: interpolate core-apps where needed, convert to helm, or use native k8s app module
data "kubectl_path_documents" "docs" {
  pattern = "${path.module}/manifests/*.yaml"
}

data "aws_eks_cluster" "eks" {
  name = module.eks_cluster.eks_cluster_id
  tags = var.tags
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks_cluster.eks_cluster_id
}
