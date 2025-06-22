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
  eks_addons = {
    vpc-cni = {
    }

    kube-proxy = {} # version will default to latest
    coredns    = {}
  }
}

resource "kubectl_manifest" "node_class" {
  depends_on = [module.eks_cluster]
  yaml_body = templatefile(
    "${path.module}/node-class.yaml",
    {
      namespace     = "arc"
      environment   = "poc"
      cluster_name  = "${var.namespace}-${var.environment}-cluster"
      map_tag_value = "dummy345fg"
    }
  )
}
