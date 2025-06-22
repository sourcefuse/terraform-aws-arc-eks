locals {

  vpc_config = {
    # security_group_ids     = []
    subnet_ids             = data.aws_subnets.private.ids
    endpoint_public_access = true
  }

  access_config = {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  envelope_encryption = {
    enable                      = true
    kms_deletion_window_in_days = 15
  }

  kubernetes_network_config = {
    ip_family = "ipv4"
  }

  auto_mode_config = {
    enable        = true
    node_pools    = ["general-purpose"]
    node_role_arn = "arn:aws:iam::341707006720:role/AmazonEKSAutoNodeRole" // TODO:
  }
}
