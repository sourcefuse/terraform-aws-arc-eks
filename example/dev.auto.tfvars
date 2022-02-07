region                            = "us-east-1"
environment                       = "dev"
profile                           = "sf_ref_arch"
namespace                         = "refarch"
route_53_zone                     = "sfrefarch.com"
availability_zones                = ["us-east-1a", "us-east-1b"]
name                              = "primary-k8s"
kubernetes_version                = "1.21"
oidc_provider_enabled             = true
enabled_cluster_log_types         = ["audit"]
cluster_log_retention_period      = 7
instance_types                    = ["t3.medium"]
desired_size                      = 1
max_size                          = 25
min_size                          = 1
disk_size                         = 50
kubernetes_labels                 = {}
cluster_encryption_config_enabled = true
addons = [
  {
    addon_name = "vpc-cni"
    #    addon_version            = "v1.9.1-eksbuild.1"
    addon_version            = null
    resolve_conflicts        = "NONE"
    service_account_role_arn = null
  }
]
kubernetes_namespace = "sf-ref-arch"
// TODO: tighten RBAC
map_additional_iam_roles = [
  {
    username = "admin",
    groups   = ["system:masters"],
    rolearn  = "arn:aws:iam::757583164619:role/sourcefuse-poc-2-admin-role"
  }
]
vpc_name = "refarch-dev-vpc"
private_subnet_names = [
  "refarch-dev-privatesubnet-private-us-east-1a",
  "refarch-dev-privatesubnet-private-us-east-1b"
]
public_subnet_names = [
  "refarch-dev-publicsubnet-public-us-east-1a",
  "refarch-dev-publicsubnet-public-us-east-1b"
]
tags = {
  Environment = "dev"
  ENV         = "dev"
  Project     = "sf-ref-arch"
  Creator     = "terraform"
}
health_check_domains = ["healthcheck.sfrefarch.com"]
