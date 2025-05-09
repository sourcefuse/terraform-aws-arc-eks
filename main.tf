resource "aws_eks_cluster" "this" {
  name                          = var.name
  version                       = var.kubernetes_version
  enabled_cluster_log_types     = var.enabled_cluster_log_types
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons_enabled

  access_config {
    authentication_mode                         = var.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.access_config.bootstrap_cluster_creator_admin_permissions
  }

  role_arn = aws_iam_role.this.arn

  vpc_config {
    security_group_ids      = var.vpc_config.security_group_ids
    subnet_ids              = var.vpc_config.subnet_ids
    endpoint_private_access = var.vpc_config.endpoint_private_access
    endpoint_public_access  = var.vpc_config.endpoint_public_access
    public_access_cidrs     = var.vpc_config.public_access_cidrs
  }

  dynamic "encryption_config" {
    for_each = var.envelope_encryption.enable ? [1] : []
    content {
      resources = var.envelope_encryption.resources
      provider {
        key_arn = var.envelope_encryption.key_arn == null ? module.kms[0].key_arn : var.envelope_encryption.key_arn
      }
    }
  }

  dynamic "zonal_shift_config" {
    for_each = var.enable_arc_zonal_shift ? [true] : []
    content {
      enabled = var.enable_arc_zonal_shift
    }
  }


  upgrade_policy {
    support_type = var.upgrade_policy
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.kubernetes_network_config.ipv4_cidr
    ip_family         = var.kubernetes_network_config.ip_family

    dynamic "elastic_load_balancing" {
      for_each = var.auto_mode_config.enable ? [1] : []
      content {
        enabled = true
      }
    }

  }

  dynamic "compute_config" {
    for_each = var.auto_mode_config.enable ? [1] : []
    content {
      enabled       = true
      node_pools    = var.auto_mode_config.node_pools
      node_role_arn = var.auto_mode_config.node_role_arn == null ? aws_iam_role.auto[0].arn : var.auto_mode_config.node_role_arn
    }
  }


  dynamic "storage_config" {
    for_each = var.auto_mode_config.enable ? [1] : []
    content {
      block_storage {
        enabled = true
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = var.tags
}

resource "aws_iam_role" "this" {
  name = "${var.name}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  for_each   = local.eks_policy_arns
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

data "tls_certificate" "this" {
  count = var.enable_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.enable_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  tags            = var.tags
}

resource "aws_security_group_rule" "cluster_ingress_rules" {
  for_each = {
    for idx, rule in var.additional_cluster_security_group_rules : idx => rule
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = try(each.value.cidr_blocks, [])
  ipv6_cidr_blocks  = try(each.value.ipv6_cidr_blocks, [])
  description       = try(each.value.description, null)
  security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}


################################################################################
# AddOn
################################################################################

resource "aws_eks_addon" "this" {
  for_each = var.eks_addons

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.key

  addon_version               = try(each.value.addon_version, null)
  service_account_role_arn    = try(each.value.service_account_role_arn, null)
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")

  tags = {
    "Name" = each.key
  }

  depends_on = [aws_eks_cluster.this,
    aws_eks_node_group.this,
    aws_eks_fargate_profile.this
  ]
}
