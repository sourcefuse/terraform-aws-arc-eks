module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["cluster"]

  context = module.this.context
}

module "eks_cluster" {
  source                       = "cloudposse/eks-cluster/aws"
  version                      = "2.5.0"
  allowed_security_groups      = var.allowed_security_groups
  region                       = var.region
  vpc_id                       = data.aws_vpc.vpc.id
  subnet_ids                   = concat(sort(data.aws_subnets.private.ids), sort(data.aws_subnets.public.ids))
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

  apply_config_map_aws_auth                 = var.apply_config_map_aws_auth
  kube_data_auth_enabled                    = var.kube_data_auth_enabled
  kubernetes_config_map_ignore_role_changes = var.kubernetes_config_map_ignore_role_changes
  kube_exec_auth_enabled                    = var.kube_exec_auth_enabled

  tags = var.tags
}

module "eks_fargate_profile" {
  source  = "cloudposse/eks-fargate-profile/aws"
  version = "1.1.0"

  subnet_ids                              = data.aws_subnets.private.ids
  cluster_name                            = local.cluster_name
  kubernetes_namespace                    = kubernetes_namespace.default_namespace[0].metadata[0].name
  kubernetes_labels                       = var.kubernetes_labels
  iam_role_kubernetes_namespace_delimiter = "@"

  context = module.this.context

  tags = var.tags
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

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "2.6.0"

  subnet_ids                 = data.aws_subnets.private.ids
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

  tags = var.tags
}

module "cluster_autoscaler_helm" {
  source = "git@github.com:lablabs/terraform-aws-eks-cluster-autoscaler?ref=v2.0.0"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_name                     = module.eks_cluster.eks_cluster_id
  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  values = yamlencode({
    "image" : {
      "tag" : "v1.21.2"
    }
  })

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}
