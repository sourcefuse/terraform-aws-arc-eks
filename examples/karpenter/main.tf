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
  name                      = "${var.namespace}-${var.environment}-cluster"
  vpc_config                = local.vpc_config
  access_config             = local.access_config
  enable_oidc_provider      = true
  envelope_encryption       = local.envelope_encryption
  kubernetes_network_config = local.kubernetes_network_config

  node_group_config = {
    enable = true
    config = {
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

  }
  eks_addons = {
    vpc-cni = {
      addon_version = "v1.19.0-eksbuild.1"
    }

    kube-proxy = {} # version will default to latest
  }
  karpenter_config = {
    enable                        = true
    name                          = "karpenter"
    namespace                     = "karpenter"
    create_namespace              = true
    chart                         = "karpenter"
    karpenter_version             = "0.36.0"
    additional_node_role_policies = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]

    helm_release_values = [file("${path.module}/karpenter-helm-values.yaml")]

    helm_release_set_values = [
      {
        name  = "dnsPolicy"
        value = "Default" # This ensures that Karpenter reaches out to the VPC DNS service when running its controllers, allowing Karpenter to start-up without the DNS application pods running, enabling Karpenter to manage the capacity for these pods.
      }
    ]
  }
  tags = module.tags.tags
}

# Tag the security group for Karpenter node discovery.
# Ensure all security groups intended for use by Karpenter-managed nodes are tagged accordingly.
# This enables Karpenter to automatically discover and associate the appropriate security groups.
resource "aws_ec2_tag" "karpenter_discovery_security_group" {
  resource_id = module.eks_cluster.eks_cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = module.eks_cluster.name
}

# Tag the subnets for Karpenter node discovery.
# All subnets intended for provisioning Karpenter-managed nodes must include this tag.
# Karpenter uses it to automatically discover and launch nodes into the correct subnets.
resource "aws_ec2_tag" "karpenter_discovery_subnets" {
  for_each = toset(data.aws_subnets.private.ids)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = module.eks_cluster.name
}

####################################################################################################
# example for ec2nodeclass, nodepool and workload
####################################################################################################
resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body  = file("${path.module}/karpenter-nodeclass.yaml")
  depends_on = [module.eks_cluster]
}

resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body  = file("${path.module}/karpenter-nodepool.yaml")
  depends_on = [kubectl_manifest.karpenter_nodeclass]
}

resource "kubectl_manifest" "inflate_deployment" {
  yaml_body  = file("${path.module}/inflate_deployment.yaml")
  depends_on = [kubectl_manifest.karpenter_nodepool]
}
