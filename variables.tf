variable "environment" {
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  type        = string
}

variable "namespace" {
  type        = string
  description = <<-EOF
    Namespace your resource belongs to.
    Usually an abbreviation of your organization name, e.g. 'example' or 'arc', to help ensure generated IDs are globally unique"
  EOF
}

variable "name" {
  type        = string
  description = "EKS Cluster name"
}

variable "auto_mode_config" {
  type = object({
    enable        = optional(bool, false)
    node_pools    = optional(list(string), ["general-purpose", "system"])
    node_role_arn = optional(string, null)
  })
  description = <<-EOF
  (optional) EKS automates routine cluster tasks for compute, storage, and networking.
  When a new pod can't fit onto existing nodes, EKS creates a new node.
  EKS combines cluster infrastructure managed by AWS with integrated Kubernetes capabilities to meet application compute needs.
  EOF
  default = {
    enable = false
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Desired Kubernetes master version"
}

variable "tags" {
  type        = map(string)
  description = "Tags for EKS resources"
  default     = {}
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "A list of the desired control plane logging to enable. Valid values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
  default     = []
}
variable "enable_oidc_provider" {
  type        = bool
  description = "Whether to enable OIDC provider"
  default     = true
}

variable "envelope_encryption" {
  type = object({
    enable                      = optional(bool, true)
    kms_deletion_window_in_days = optional(number, 10)
    resources                   = optional(list(string), ["secrets"])
    key_arn                     = optional(string, null) // if null it created new KMS key
  })
  description = "Whether to enable Envelope encryption"
  default = {
    enable = true
  }
}

variable "vpc_config" {
  description = <<EOT
  Configuration block for VPC settings:
  - security_group_ids: List of security group IDs associated with the VPC.
  - subnet_ids: List of subnet IDs where resources will be deployed.
  - endpoint_private_access: Enable or disable private access to the cluster endpoint.
  - endpoint_public_access: Enable or disable public access to the cluster endpoint.
  - public_access_cidrs: CIDR blocks that can access the public endpoint (if enabled).
  EOT
  type = object({
    security_group_ids      = optional(list(string), [])
    subnet_ids              = list(string)
    endpoint_private_access = optional(bool, false)
    endpoint_public_access  = optional(bool, true)
    public_access_cidrs     = optional(list(string), ["0.0.0.0/0"])
  })
}

variable "bootstrap_self_managed_addons_enabled" {
  type        = bool
  description = "(optional) Install default unmanaged add-ons, such as aws-cni, kube-proxy, and CoreDNS during cluster creation. If false, you must manually install desired add-ons. Changing this value will force a new cluster to be created."
  default     = true
}

variable "enable_arc_zonal_shift" {
  type        = bool
  description = "(optional) Whether to enable ARC Zonal shift , it shift application traffic away from an impaired Availability Zone (AZ) in your EKS cluster. "
  default     = false
}

variable "upgrade_policy" {
  type        = string
  description = <<EOT
   (optional) Support type to use for the cluster. If the cluster is set to EXTENDED, it will enter extended support at the end of standard support.
    If the cluster is set to STANDARD, it will be automatically upgraded at the end of standard support.
    Valid values are EXTENDED, STANDARD"

    STANDARD - This option supports the Kubernetes version for 14 months after the release date. There is no additional cost. When standard support ends, your cluster will be auto upgraded to the next version.
    EXTENDED - This option supports the Kubernetes version for 26 months after the release date. The extended support period has an additional hourly cost that begins after the standard support period ends. When extended support ends, your cluster will be auto upgraded to the next version.
  EOT
  default     = "STANDARD"
  validation {
    condition     = var.upgrade_policy == "STANDARD" || var.upgrade_policy == "EXTENDED"
    error_message = "upgrade_policy must be either 'STANDARD' or 'EXTENDED'."
  }
}

variable "kubernetes_network_config" {
  type = object({
    ipv4_cidr = optional(string, null)
    ip_family = optional(string, "ipv4")
  })

  description = <<EOT
Configuration block for Kubernetes network.

- `service_ipv4_cidr`: Optional custom CIDR block for Kubernetes service IPs. Must be within 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16 and have a netmask between /12 and /24.
- `ip_family`: The IP family to assign (ipv4 or ipv6). Default is ipv4.
EOT

  validation {
    condition = (
      !contains(keys(var.kubernetes_network_config), "service_ipv4_cidr") ||
      can(regex("^((10\\.|172\\.(1[6-9]|2[0-9]|3[0-1])|192\\.168)\\.(\\d{1,3})\\.(\\d{1,3}))/([1][2-9]|2[0-4])$", var.kubernetes_network_config.service_ipv4_cidr))
    )
    error_message = "service_ipv4_cidr must be a valid CIDR block within 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16 and have a subnet mask between /12 and /24."
  }

  validation {
    condition = (
      contains(["ipv4", "ipv6"], var.kubernetes_network_config.ip_family)
    )
    error_message = "ip_family must be either 'ipv4' or 'ipv6'."
  }

  default = {
    ip_family = "ipv4"
  }
}




variable "eks_policy_arns" {
  description = "List of IAM policy ARNs to attach to the EKS role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"

  ]
}

variable "eks_additional_policy_arns" {
  description = "Optional additional policy ARNs that user wants to attach"
  type        = list(string)
  default     = []
}

variable "additional_cluster_security_group_rules" {
  description = "List of ingress security group rules to apply to the EKS cluster security group"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    description      = optional(string)
  }))
  default = []
}


################################################################################
# Node Group
################################################################################

variable "node_group_config" {
  type = map(object({
    node_group_name = optional(string)
    node_role_arn   = optional(string)
    release_version = optional(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }))
    remote_access = optional(object({
      ec2_ssh_key               = string
      source_security_group_ids = list(string)
    }))
    launch_template = optional(object({
      id      = optional(string)
      name    = optional(string)
      version = string
    }))
    node_repair_config = optional(object({
      enabled = bool
    }))
    instance_types      = optional(list(string), ["t3.medium"])
    ami_type            = optional(string)
    disk_size           = optional(number)
    capacity_type       = optional(string, "ON_DEMAND")
    labels              = optional(map(string), {})
    ignore_desired_size = optional(bool, false)
    subnet_ids          = list(string)
    kubernetes_version  = optional(string)
  }))
  default = {}
}
variable "node_group_policy_arns" {
  description = "Default policies for EKS node group"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

variable "additional_node_group_policy_arns" {
  description = "Optional additional policies to attach to node group role"
  type        = list(string)
  default     = []
}

################################################################################
# AddOn
################################################################################

variable "eks_addons" {
  description = "Map of EKS Add-ons to create"
  type = map(object({
    addon_version               = optional(string)
    service_account_role_arn    = optional(string)
    resolve_conflicts_on_update = optional(string)
    resolve_conflicts_on_create = optional(string)
  }))
  default = {}
}



# ################################################################################
# # access config
# ################################################################################

variable "access_config" {
  description = <<-EOT
  Access configuration for the cluster.
  - `authentication_mode`: One of "API" or "API_AND_CONFIG_MAP"
  - `bootstrap_cluster_creator_admin_permissions`: Grant creator admin access
  - `aws_auth_config_map`: (optional) Config for aws-auth ConfigMap
  - `eks_access_entries`: (optional) List of principals and their policy associations
  EOT

  type = object({
    authentication_mode                         = optional(string, "API")
    bootstrap_cluster_creator_admin_permissions = optional(bool, false)

    aws_auth_config_map = optional(object({
      create   = optional(bool, false)
      manage   = optional(bool, false)
      roles    = optional(list(any), [])
      users    = optional(list(any), [])
      accounts = optional(list(string), [])
    }), {})

    eks_access_entries = optional(list(object({
      principal_arn = optional(string)
      policy_arns   = optional(list(string))
      access_scope = optional(object({
        type       = string
        namespaces = optional(list(string))
      }))
    })), [])
  })

  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP"], var.access_config.authentication_mode)
    error_message = "authentication_mode must be one of 'API' or 'API_AND_CONFIG_MAP'."
  }

  default = {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }
}

################################################################################
# Fargate Profile
################################################################################

variable "fargate_profile_config" {
  description = "Combined configuration for the EKS Fargate profile, including IAM policies."
  type = object({
    fargate_profile_name   = optional(string)
    pod_execution_role_arn = optional(string)
    subnet_ids             = optional(list(string))
    selectors = optional(list(object({
      namespace = string
      labels    = optional(map(string))
    })))
    tags                   = optional(map(string), {})
    policy_arns            = optional(list(string), ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"])
    additional_policy_arns = optional(list(string), [])
  })
  default = {}
}


################################################################################
# karpenter_config
################################################################################

variable "karpenter_config" {
  description = "Configuration for Karpenter"
  type = object({
    enable                                  = bool
    name                                    = optional(string)
    namespace                               = optional(string, "karpenter")
    create_namespace                        = optional(bool)
    karpenter_version                       = optional(string, "0.36.0")
    helm_repository                         = optional(string, "oci://public.ecr.aws/karpenter")
    chart                                   = optional(string)
    additional_karpenter_node_role_policies = optional(list(string), [])
    helm_release_values                     = optional(any)
    helm_release_set_values = optional(list(object({
      name  = string
      value = string
    })), [])
  })
  default = {
    enable = false
  }
}
