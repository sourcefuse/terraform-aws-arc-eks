resource "helm_release" "karpenter" {
  count            = var.karpenter_config.enable ? 1 : 0
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  repository       = var.karpenter_config.helm_repository
  chart            = "karpenter"
  version          = var.karpenter_config.karpenter_version
  values           = var.karpenter_config.helm_release_values

  dynamic "set" {
    for_each = local.merged_set_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [
    aws_iam_role_policy.karpenter_controller_policy,
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}
