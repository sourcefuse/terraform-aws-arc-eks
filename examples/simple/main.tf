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
  name                      = local.name
  vpc_config                = local.vpc_config
  access_config             = local.access_config
  enable_oidc_provider      = false
  envelope_encryption       = local.envelope_encryption
  kubernetes_network_config = local.kubernetes_network_config
  auto_mode_config = {
    enable = true
  }
  aws_auth_config = {
    create = false
    manage = true
    roles = [
      {
        rolearn = "arn:aws:iam::884360309640:role/debash-iam-role"
      }
    ]
    users    = []
    accounts = []
  }
  eks_access_entries = [
    "arn:aws:iam::884360309640:role/debash-iam-role",
    "arn:aws:iam::884360309640:role/arc-dev-test-role"
  ]

  eks_access_policy_associations = [
    {
      principal_arn = "arn:aws:iam::884360309640:role/debash-iam-role"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
      access_scope = {
        type       = "namespace"
        namespaces = ["kube-system"]
      }
    },
    {
      principal_arn = "arn:aws:iam::884360309640:role/arc-dev-test-role"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      access_scope = {
        type = "cluster"
      }
    }
  ]
}
