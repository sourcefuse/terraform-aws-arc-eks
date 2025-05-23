locals {

  vpc_config = {
    subnet_ids             = data.aws_subnets.private.ids
    endpoint_public_access = true
  }

  access_config = {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true

    aws_auth_config_map = {
      create   = false
      manage   = true
      roles    = []
      users    = []
      accounts = []
    }
  }
  envelope_encryption = {
    enable                      = true
    kms_deletion_window_in_days = 15
  }

  kubernetes_network_config = {
    ip_family = "ipv4"
  }
}
