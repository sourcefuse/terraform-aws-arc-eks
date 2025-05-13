provider "aws" {
  region = var.region
}

module "tags" {
  source      = "sourcefuse/arc-tags/aws"
  version     = "1.2.2"
  environment = var.environment
  project     = "arc"

  extra_tags = {
    Repo = "github.com/sourcefuse/terraform-aws-arc-eks"
  }
}

module "eks_cluster" {
  source                    = "../../"
  namespace                 = "arc"
  environment               = "poc"
  kubernetes_version        = "1.31"
  name                      = "${var.namespace}-${var.environment}-debash"
  vpc_config                = local.vpc_config
  access_config             = local.access_config
  enable_oidc_provider      = true
  envelope_encryption       = local.envelope_encryption
  kubernetes_network_config = local.kubernetes_network_config

  node_group_config = {
    karpenter = {
      node_group_name = "karpenter-nodegroup"
      subnet_ids      = data.aws_subnets.private.ids
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 1
      }
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 20
      ami_type       = "AL2_x86_64"
    }
  }
  eks_addons = {
    vpc-cni = {
      addon_version = "v1.19.0-eksbuild.1"
    }

    kube-proxy = {} # version will default to latest
  }

  aws_auth_config = {
    create = false
    manage = true
    roles = [
      {
        rolearn = data.aws_iam_role.karpenter_node_role.arn
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
        username = "system:node:{{EC2PrivateDNSName}}"
      }
    ]
    users    = []
    accounts = []
  }
  eks_access_entries = [
    "arn:aws:iam::884360309640:role/KarpenterNodeRole-arc-poc-debash"
  ]

  eks_access_policy_associations = [
    {
      principal_arn = "arn:aws:iam::884360309640:role/KarpenterNodeRole-arc-poc-debash"
      policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
      access_scope = {
        type = "cluster"
      }
    }
  ]



  karpenter_config = {
    enable                        = true
    karpenter_version             = "0.36.0"
    additional_node_role_policies = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]

    helm_release_values = [
      yamlencode({
        controller = {
          resources = {
            requests = {
              cpu    = "1"
              memory = "1Gi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
        },
        webhook = {
          enabled = true
        },
        certController = {
          enabled = true
        }
      })
    ]

    # helm_release_set_values = [ ] Add Additional Values for helm
  }
  tags = module.tags.tags
}
