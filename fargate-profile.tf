resource "aws_eks_fargate_profile" "this" {
  count = (
    var.fargate_profile_config != null &&
    try(length(var.fargate_profile_config.selectors), 0) > 0
  ) ? 1 : 0

  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = var.fargate_profile_config.fargate_profile_name
  pod_execution_role_arn = aws_iam_role.eks_fargate_profile[0].arn
  subnet_ids             = var.fargate_profile_config.subnet_ids
  tags                   = var.fargate_profile_config.tags

  dynamic "selector" {
    for_each = var.fargate_profile_config.selectors
    content {
      namespace = selector.value.namespace
      labels    = try(selector.value.labels, null)
    }
  }
}
