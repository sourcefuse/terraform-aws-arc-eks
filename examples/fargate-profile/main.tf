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
  fargate_profile_config = {
    fargate_profile_name   = "example"
    subnet_ids             = data.aws_subnets.private.ids
    additional_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"] # To add additional policy to Fargate Profile
    selectors = [
      {
        namespace = "example"
      }
    ]
    tags = {
      Environment = "dev"
      Project     = "example"
    }
  }

  eks_addons = {
    vpc-cni = {
      addon_version = "v1.19.0-eksbuild.1"
    }

    kube-proxy = {} # version will default to latest
  }


}
