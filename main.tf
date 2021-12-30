module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["cluster"]

  context = module.this.context
}

module "tags" {
  source = "git::ssh://git@github.com/sourcefuse/terraform-aws-ref-arch-eks.git//terraform-refarch-tags?ref=50a1aaf14d3c348f866f4cd02869924b7bf3359c"

  environment = var.environment
  project     = var.project
  role        = "${var.project}-${var.environment}-eks-cluster"
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.43.2"

  region                       = var.region
  vpc_id                       = data.aws_vpc.vpc.id
  subnet_ids                   = concat(sort(data.aws_subnet_ids.private.ids), sort(data.aws_subnet_ids.public.ids))
  kubernetes_version           = var.kubernetes_version
  local_exec_interpreter       = var.local_exec_interpreter
  oidc_provider_enabled        = var.oidc_provider_enabled
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  cluster_log_retention_period = var.cluster_log_retention_period
  map_additional_iam_roles     = var.map_additional_iam_roles

  cluster_encryption_config_enabled                         = var.cluster_encryption_config_enabled
  cluster_encryption_config_kms_key_id                      = var.cluster_encryption_config_kms_key_id
  cluster_encryption_config_kms_key_enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  cluster_encryption_config_kms_key_deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  cluster_encryption_config_kms_key_policy                  = var.cluster_encryption_config_kms_key_policy
  cluster_encryption_config_resources                       = var.cluster_encryption_config_resources

  addons = var.addons

  context = module.this.context
  // TODO: make configurable
  #    apply_config_map_aws_auth                 = true
  #    kube_data_auth_enabled                    = true
  #    kubernetes_config_map_ignore_role_changes = true
  #    kube_exec_auth_enabled                    = true

  tags = merge(module.tags.tags, var.tags)
}

module "eks_fargate_profile" {
  source  = "cloudposse/eks-fargate-profile/aws"
  version = "0.9.2"

  subnet_ids                              = data.aws_subnet_ids.private.ids
  cluster_name                            = local.cluster_name
  kubernetes_namespace                    = kubernetes_namespace.default_namespace[0].metadata[0].name
  kubernetes_labels                       = var.kubernetes_labels
  iam_role_kubernetes_namespace_delimiter = "@"

  context = module.this.context

  tags = merge(module.tags.tags, var.tags)
}


resource "kubernetes_namespace" "default_namespace" {
  count = (var.enabled && var.kubernetes_namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.kubernetes_namespace
  }

  depends_on = [
    module.eks_cluster
  ]
}

//TODO: nodes for the core-apps and other services
// once those are cleaned up, they can have their own node groups or use fargate
module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.26.0"

  subnet_ids                 = data.aws_subnet_ids.private.ids
  cluster_name               = module.eks_cluster.eks_cluster_id
  instance_types             = var.instance_types
  desired_size               = var.desired_size
  min_size                   = var.min_size
  max_size                   = var.max_size
  kubernetes_labels          = var.kubernetes_labels
  cluster_autoscaler_enabled = true

  # Prevent the node groups from being created before the Kubernetes aws-auth ConfigMap
  module_depends_on = module.eks_cluster.kubernetes_config_map_id

  context = module.this.context

  tags = merge(module.tags.tags, var.tags)
}
