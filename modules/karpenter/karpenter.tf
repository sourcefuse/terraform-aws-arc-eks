resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  repository       = var.karpenter_config.helm_repository
  chart            = "karpenter"
  version          = var.karpenter_config.karpenter_version

  set {
    name  = "settings.clusterName"
    value = var.karpenter_config.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.karpenter_config.cluster_endpoint
  }

  set {
    name  = "settings.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_instance_profile.name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller_role.arn
  }

  values = [
    yamlencode({
      controller = {
        resources = {
          requests = {
            cpu    = "1"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      },
      webhook = {
        enabled = true
      },
      certController = {
        enabled = true
      }
    })
  ]

  depends_on = [aws_iam_role_policy.karpenter_controller_policy]
}
