region                            = "us-east-1"
environment                       = "poc"
namespace                         = "arc"
route_53_zone                     = "sfarcpoc.com"
name                              = "sl-k8s"
kubernetes_version                = "1.25"
oidc_provider_enabled             = true
enabled_cluster_log_types         = ["audit"]
cluster_log_retention_period      = 7
instance_types                    = ["t3.medium"]
desired_size                      = 3
max_size                          = 8
min_size                          = 3
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
health_check_domains = ["healthcheck-example.sfarcpoc.com"]
