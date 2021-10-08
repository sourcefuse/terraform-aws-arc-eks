region      = "us-east-1"
environment = "dev"
profile     = "sf_ref_arch"
namespace   = "refarch"

availability_zones = ["us-east-1a", "us-east-1b"]

name = "primary-k8s-cluster"

kubernetes_version = "1.21"

oidc_provider_enabled = true

enabled_cluster_log_types = ["audit"]

cluster_log_retention_period = 7

instance_types = ["t3.small"]

desired_size = 2

max_size = 3

min_size = 2

disk_size = 20

kubernetes_labels = {}

cluster_encryption_config_enabled = true

addons = [
  {
    addon_name               = "vpc-cni"
    addon_version            = null
    resolve_conflicts        = "NONE"
    service_account_role_arn = null
  }
]

kubernetes_namespace = "sf-ref-arch"
map_additional_iam_roles = [
  {
    username = "admin",
    groups   = ["system:masters"],
    rolearn  = "arn:aws:iam::757583164619:role/sourcefuse-poc-2-admin-role"
  }
]
