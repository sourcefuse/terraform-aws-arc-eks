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
  source                                = "../../"
  namespace                             = "arc"
  environment                           = "poc"
  kubernetes_version                    = "1.31"
  name                                  = "${var.namespace}-${var.environment}-cluster"
  vpc_config                            = local.vpc_config
  auto_mode_config                      = local.auto_mode_config
  bootstrap_self_managed_addons_enabled = false
  access_config                         = local.access_config
  enable_oidc_provider                  = false
  envelope_encryption                   = local.envelope_encryption
  kubernetes_network_config             = local.kubernetes_network_config
}


// "errorMessage": "User: arn:aws:sts::884360309640:assumed-role/arc-poc-k8s-eks-role/aws-go-sdk-1744220212198998255
// is not authorized to perform: iam:AddRoleToInstanceProfile on resource: instance profile eks-us-east-1-arc-poc-k8s-6339084366055886033
// because no identity-based policy allows the iam:AddRoleToInstanceProfile action
