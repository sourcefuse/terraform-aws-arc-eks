################################################################################
# aws-auth configmap
################################################################################

resource "kubernetes_config_map" "aws_auth" {
  count = var.aws_auth_config.create ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1" "aws_auth" {
  count = var.aws_auth_config.manage ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  depends_on = [
    kubernetes_config_map.aws_auth,
  ]
}

################################################################################
# aws eks access entry
################################################################################

resource "aws_eks_access_entry" "this" {
  for_each = toset(var.eks_access_entries)

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
}
resource "aws_eks_access_policy_association" "this" {
  for_each = {
    for idx, assoc in local.all_access_associations :
    idx => assoc
  }

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
