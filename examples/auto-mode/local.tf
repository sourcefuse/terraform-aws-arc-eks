locals {

  vpc_config = {
    security_group_ids     = [module.arc_security_group.id]
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
    enable     = true
    node_pools = ["general-purpose", "system"]
  }

}

locals {
  security_group_data = {
    create      = true
    description = "Additional Security Group"

    ingress_rules = [
      {
        description = "Allow VPC traffic"
        cidr_block  = data.aws_vpc.vpc.cidr_block
        from_port   = 0
        ip_protocol = "tcp"
        to_port     = 88
      },
      {
        description = "Allow traffic from self"
        self        = true
        from_port   = 0
        ip_protocol = "tcp"
        to_port     = 443
      },
    ]

    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0"
        from_port   = -1
        ip_protocol = "-1"
        to_port     = -1
      }
    ]
  }
}
