provider "aws" {
  region = var.region
}

module "tags" {
  source      = "sourcefuse/arc-tags/aws"
  version     = "1.2.2"
  environment = var.environment
  project     = "arc"

  extra_tags = {
    Repo = "github.com/sourcefuse/terraform-aws-arc-eks"
  }
}

module "eks_cluster" {
  source                    = "../../"
  namespace                 = "arc"
  environment               = "dev"
  kubernetes_version        = "1.31"
  name                      = "${var.namespace}-${var.environment}-cluster"
  vpc_config                = local.vpc_config
  access_config             = local.access_config
  enable_oidc_provider      = false
  envelope_encryption       = local.envelope_encryption
  kubernetes_network_config = local.kubernetes_network_config
  # eks_additional_policy_arns =["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]   To add additional policy to EKS Cluster
  node_group_config = {
    general-ng = {
      node_group_name = "general-nodegroup"
      subnet_ids      = data.aws_subnets.private.ids
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 1
      }
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 20
      ami_type       = "AL2_x86_64"
    }
    spot-ng = {
      node_group_name = "spot-nodegroup"
      subnet_ids      = data.aws_subnets.private.ids
      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 1
      }
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      disk_size      = 20
      ami_type       = "AL2_x86_64"
    }
  }
  eks_addons = {
    vpc-cni = {
      addon_version = "v1.19.0-eksbuild.1"
    }

    kube-proxy = {} # version will default to latest
  }
  tags = module.tags
}
