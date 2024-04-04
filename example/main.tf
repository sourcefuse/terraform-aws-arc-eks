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
  source                    = "sourcefuse/arc-eks/aws"
  version                   = "5.0.5"
  environment               = var.environment
  name                      = var.name
  namespace                 = var.namespace
  desired_size              = var.desired_size
  instance_types            = var.instance_types
  kubernetes_namespace      = var.kubernetes_namespace
  create_node_group         = true
  max_size                  = var.max_size
  min_size                  = var.min_size
  subnet_ids                = data.aws_subnets.private.ids
  region                    = var.region
  vpc_id                    = data.aws_vpc.vpc.id
  enabled                   = true
  kubernetes_version        = var.kubernetes_version
  apply_config_map_aws_auth = true
  kube_data_auth_enabled    = true
  kube_exec_auth_enabled    = true
  #  csi_driver_enabled        = var.csi_driver_enabled
  map_additional_iam_roles = var.map_additional_iam_roles
  allowed_security_groups  = concat(data.aws_security_groups.eks_sg.ids, data.aws_security_groups.db_sg.ids)
}
