################################################################################
# EKS Capabilities
################################################################################

resource "aws_eks_capability" "this" {
  for_each = var.eks_capabilities_config.enable ? {
    for capability in var.eks_capabilities_config.capabilities : capability.name => capability
  } : {}

  cluster_name              = aws_eks_cluster.this.name
  capability_name           = each.value.capability_name
  type                      = each.value.type
  delete_propagation_policy = try(each.value.delete_propagation_policy, "RETAIN")
  role_arn                  = each.value.role_arn

  dynamic "configuration" {
    for_each = each.value.type == "ARGOCD" && try(each.value.argocd_config, null) != null ? [1] : []
    content {
      dynamic "argo_cd" {
        for_each = each.value.type == "ARGOCD" && try(each.value.argocd_config, null) != null ? [1] : []
        content {
          namespace = try(each.value.argocd_config.namespace, "argocd")

          # AWS IAM Identity Center (required by provider, but we provide empty if not specified)
          dynamic "aws_idc" {
            for_each = try(each.value.argocd_config.aws_idc, null) != null ? [each.value.argocd_config.aws_idc] : []
            content {
              idc_instance_arn = aws_idc.value.idc_instance_arn
              idc_region       = try(aws_idc.value.idc_region, null)
            }
          }

          dynamic "network_access" {
            for_each = try(each.value.argocd_config.network_access, null) != null ? [each.value.argocd_config.network_access] : []
            content {
              vpce_ids = try(network_access.value.vpce_ids, null)
            }
          }

          dynamic "rbac_role_mapping" {
            for_each = try(each.value.argocd_config.rbac_role_mapping, null) != null ? each.value.argocd_config.rbac_role_mapping : []
            content {
              role = rbac_role_mapping.value.role

              dynamic "identity" {
                for_each = rbac_role_mapping.value.identity
                content {
                  id   = identity.value.id
                  type = identity.value.type
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_eks_cluster.this]
}