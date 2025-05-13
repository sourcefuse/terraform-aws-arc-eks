locals {
  eks_policy_arns             = toset(concat(var.eks_policy_arns, var.eks_additional_policy_arns))
  node_group_policy_arns      = toset(concat(var.node_group_policy_arns, var.additional_node_group_policy_arns))
  fargate_profile_policy_arns = toset(concat(var.fargate_profile_policy_arns, var.additional_fargate_profile_policy_arns))

  ################################################################################
  # aws-auth configmap
  ################################################################################

  aws_auth_configmap_data = {
    mapRoles    = yamlencode(lookup(var.aws_auth_config, "roles", []))
    mapUsers    = yamlencode(lookup(var.aws_auth_config, "users", []))
    mapAccounts = yamlencode(lookup(var.aws_auth_config, "accounts", []))
  }


  ################################################################################
  # aws eks access entry
  ################################################################################

  creator_access = var.enable_creator_admin_access ? [{
    principal_arn = data.aws_iam_session_context.this.issuer_arn
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
    access_scope = {
      type = "cluster"
    }
  }] : []

  all_access_associations = concat(local.creator_access, var.eks_access_policy_associations)


  ################################################################################
  # karpenter
  ################################################################################

  karpenter_node_role_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]

  all_karpenter_node_role_policies = concat(
    local.karpenter_node_role_policies,
    var.karpenter_config.additional_karpenter_node_role_policies
  )
  required_set_values = [
    {
      name  = "settings.clusterName"
      value = aws_eks_cluster.this.name
    },
    {
      name  = "settings.clusterEndpoint"
      value = aws_eks_cluster.this.endpoint
    },
    {
      name  = "settings.defaultInstanceProfile"
      value = aws_iam_instance_profile.karpenter_instance_profile[0].name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter_controller_role[0].arn
    }
  ]

  merged_set_values = concat(local.required_set_values, try(var.karpenter_config.helm_release_set_values, []))
}
