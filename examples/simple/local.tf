locals {

  vpc_config = {
    subnet_ids             = data.aws_subnets.private.ids
    endpoint_public_access = true
  }

  access_config = {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
    aws_auth_config_map = {
      create   = false
      manage   = true
      roles    = []
      users    = []
      accounts = []
    }
    eks_access_entries = [
      {
        principal_arn = data.aws_iam_session_context.this.issuer_arn
        policy_arns = [
          "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        ]
        access_scope = {
          type = "cluster"
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
