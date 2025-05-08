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
  environment               = "poc"
  kubernetes_version        = "1.31"
  name                      = "${var.namespace}-${var.environment}-debash"
  vpc_config                = local.vpc_config
  access_config             = local.access_config
  enable_oidc_provider      = false
  envelope_encryption       = local.envelope_encryption
  kubernetes_network_config = local.kubernetes_network_config

  node_group_config = {
    karpenter = {
      node_group_name = "karpenter-nodegroup"
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
  }
  eks_addons = {
    vpc-cni = {
      addon_version = "v1.19.0-eksbuild.1"
    }

    kube-proxy = {} # version will default to latest
  }


  tags = module.tags.tags
}


################################################################################
# Karpenter
################################################################################

module "karpenter" {
  source = "../../modules/karpenter"
  providers = {
    helm = helm
  }
  karpenter_config = {
    cluster_name               = module.eks_cluster.name
    cluster_endpoint           = module.eks_cluster.endpoint
    cluster_oidc_provider      = module.eks_cluster.oidc_provider_url
    cluster_arn                = module.eks_cluster.arn
    certificate_authority_data = module.eks_cluster.certificate_authority_data
  }

  depends_on = [module.eks_cluster.eks_cluster_id]
}
