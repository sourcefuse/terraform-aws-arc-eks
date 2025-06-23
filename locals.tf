locals {
  eks_policy_arns        = toset(concat(var.eks_policy_arns, var.eks_additional_policy_arns))
  node_group_policy_arns = toset(concat(var.node_group_policy_arns, var.additional_node_group_policy_arns))
  fargate_profile_policy_arns = toset(concat(try(var.fargate_profile_config.policy_arns, []), try(var.fargate_profile_config.additional_policy_arns, [])
  ))

  ################################################################################
  # aws-auth configmap
  ################################################################################

  aws_auth_config_base = lookup(var.access_config, "aws_auth_config_map", {})

  # Conditionally add Karpenter role if enabled
  aws_auth_config = merge(
    local.aws_auth_config_base,
    {
      roles = concat(
        lookup(local.aws_auth_config_base, "roles", []),
        var.karpenter_config.enable ? [
          {
            rolearn  = aws_iam_role.karpenter_node_role[0].arn
            groups   = ["system:bootstrappers", "system:nodes"]
            username = "system:node:{{EC2PrivateDNSName}}"
          }
        ] : []
      )
    }
  )

  aws_auth_enabled = var.access_config.authentication_mode == "API_AND_CONFIG_MAP"

  aws_auth_configmap_data = {
    mapRoles    = yamlencode(lookup(local.aws_auth_config, "roles", []))
    mapUsers    = yamlencode(lookup(local.aws_auth_config, "users", []))
    mapAccounts = yamlencode(lookup(local.aws_auth_config, "accounts", []))
  }



  # ################################################################################
  # # aws eks access entry
  # ################################################################################

  eks_api_enabled = contains(["API", "API_AND_CONFIG_MAP"], var.access_config.authentication_mode)

  # User-defined access entries
  user_defined_access = try(var.access_config.eks_access_entries, [])

  # Flatten user-defined policy associations
  expanded_access_associations = flatten([
    for assoc in local.user_defined_access : [
      for policy_arn in assoc.policy_arns : {
        principal_arn = assoc.principal_arn
        policy_arn    = policy_arn
        access_scope  = assoc.access_scope
      }
    ]
  ])

  # Unique map of policy associations, keyed by principal and policy ARN
  all_access_associations = {
    for assoc in local.expanded_access_associations :
    "${assoc.principal_arn}|${assoc.policy_arn}" => assoc
  }

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
      value = var.karpenter_config.enable ? aws_iam_instance_profile.karpenter_instance_profile[0].name : ""
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.karpenter_config.enable ? aws_iam_role.karpenter_controller_role[0].arn : ""
    }
  ]

  merged_set_values = concat(local.required_set_values, try(var.karpenter_config.helm_release_set_values, []))
}
