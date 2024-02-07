region                            = "us-east-1"
environment                       = "poc"
namespace                         = "arc"
route_53_zone                     = "sfarcpoc.com"
name                              = "sl-k8s"
kubernetes_version                = "1.28"
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
  // https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version
  {
    addon_name                  = "vpc-cni"
    addon_version               = null
    resolve_conflicts_on_create = "NONE"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = null
  },
  // https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  {
    addon_name                  = "kube-proxy"
    addon_version               = null
    resolve_conflicts_on_create = "NONE"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = null
  },
  // https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
  {
    addon_name                  = "coredns"
    addon_version               = null
    resolve_conflicts_on_create = "NONE"
    resolve_conflicts_on_update = "NONE"
    service_account_role_arn    = null
  },
]
kubernetes_namespace = "sf-ref-arch"
// TODO: tighten RBAC (define more fine-grained ddefault groups for like developers, devops, testers. developers, and testers should be restricted to a particular namespace(roles, rolebindings), devops should have clusterroles, clusterolebindings)
map_additional_iam_roles = [
  {
    username = "admin",
    groups   = ["system:masters"],
    rolearn  = "arn:aws:iam::757583164619:role/sourcefuse-poc-2-admin-role"
  }
]
health_check_domains = ["healthcheck-example.sfarcpoc.com"]
