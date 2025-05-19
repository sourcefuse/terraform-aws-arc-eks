locals {

  vpc_config = {
    //security_group_ids      = var.vpc_config.security_group_ids // TODO
    subnet_ids             = data.aws_subnets.private.ids
    endpoint_public_access = true
  }

  access_config = {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
    aws_auth_config = {
    create = false
    manage = true
    roles = [
      {
        rolearn = ""
      }
    ]
    users    = []
    accounts = []
  }
  eks_access_entries = [
      "",
    ]

    eks_access_policy_associations = [
      {
        principal_arn = ""
        policy_arn    = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy","arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy" ]
        access_scope = {
          type       = "namespace"
          namespaces = ["karpenter", "default"]
        }
      }
    ]
  }
  envelope_encryption = {
    enable                      = true
    kms_deletion_window_in_days = 15
  }

  kubernetes_network_config = {
    ip_family = "ipv4"
  }

}
