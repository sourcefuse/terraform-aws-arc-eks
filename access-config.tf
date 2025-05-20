# ################################################################################
# # aws-auth configmap
# ################################################################################
resource "kubernetes_config_map" "aws_auth" {
  count = (local.aws_auth_enabled && var.access_config.aws_auth_config_map.create) ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = (local.aws_auth_enabled && var.access_config.aws_auth_config_map.manage) ? 1 : 0
  force = true
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  depends_on = [
    kubernetes_config_map.aws_auth
  ]
}

# ################################################################################
# # aws eks access entry
# ################################################################################

resource "aws_eks_access_entry" "this" {
  for_each = local.eks_api_enabled ? {
    for principal_arn in toset([
      for assoc in local.expanded_access_associations : assoc.principal_arn
    ]) : principal_arn => principal_arn
  } : {}

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "this" {
  for_each = local.eks_api_enabled ? local.all_access_associations : tomap({})

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = lookup(each.value.access_scope, "namespaces", null)
  }

  depends_on = [
    aws_eks_access_entry.this
  ]
}
