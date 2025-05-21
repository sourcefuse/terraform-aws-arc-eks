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
}
