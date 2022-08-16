## default
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

## network
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = var.private_subnet_names
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = var.public_subnet_names
  }
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
