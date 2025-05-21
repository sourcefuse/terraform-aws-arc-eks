resource "aws_eks_node_group" "this" {
  for_each = var.node_group_config.enable ? var.node_group_config.config : {}

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.node_group_name
  node_role_arn   = aws_iam_role.eks_node_group[each.key].arn
  subnet_ids      = each.value.subnet_ids
  version         = try(each.value.kubernetes_version, null)
  release_version = each.value.release_version

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  dynamic "taint" {
    for_each = each.value.taints != null ? each.value.taints : []
    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  dynamic "update_config" {
    for_each = each.value.update_config != null ? [1] : []
    content {
      max_unavailable            = try(each.value.update_config.max_unavailable, null)
      max_unavailable_percentage = try(each.value.update_config.max_unavailable_percentage, null)
    }
  }

  dynamic "remote_access" {
    for_each = each.value.remote_access != null ? [1] : []
    content {
      ec2_ssh_key               = each.value.remote_access.ec2_ssh_key
      source_security_group_ids = each.value.remote_access.source_security_group_ids
    }
  }

  dynamic "launch_template" {
    for_each = each.value.launch_template != null ? [1] : []
    content {
      id      = try(each.value.launch_template.id, null)
      name    = try(each.value.launch_template.name, null)
      version = each.value.launch_template.version
    }
  }

  dynamic "node_repair_config" {
    for_each = each.value.node_repair_config != null ? [1] : []
    content {
      enabled = each.value.node_repair_config.enabled
    }
  }

  instance_types = try(each.value.instance_types, [])
  ami_type       = try(each.value.ami_type, "")
  disk_size      = try(each.value.disk_size, null)
  capacity_type  = try(each.value.capacity_type, "")
  labels         = try(each.value.labels, {})

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [aws_eks_cluster.this]
}
