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
    for_each = try(var.karpenter_config.helm_release_set_values, [])
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



# resource "helm_release" "karpenter" {
#   count = var.karpenter_config.enable ? 1 : 0
#   name             = "karpenter"
#   namespace        = "karpenter"
#   create_namespace = true
#   repository       = var.karpenter_config.helm_repository
#   chart            = "karpenter"
#   version          = var.karpenter_config.karpenter_version
#   values = var.karpenter_config.helm_release_values
#   set {
#     name  = "settings.clusterName"
#     value = aws_eks_cluster.this.name
#   }

#   set {
#     name  = "settings.clusterEndpoint"
#     value = aws_eks_cluster.this.endpoint
#   }

#   set {
#     name  = "settings.defaultInstanceProfile"
#     value = aws_iam_instance_profile.karpenter_instance_profile[0].name
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.karpenter_controller_role[0].arn
#   }



#   depends_on = [aws_iam_role_policy.karpenter_controller_policy,aws_eks_cluster.this,aws_eks_node_group.this]

# }
