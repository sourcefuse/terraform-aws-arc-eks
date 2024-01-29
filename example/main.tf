provider "aws" {
  region = var.region
}

module "tags" {
  source      = "sourcefuse/arc-tags/aws"
  version     = "1.2.2"
  environment = var.environment
  project     = "arc"

  extra_tags = {
    Repo = "github.com/sourcefuse/terraform-aws-arc-bootstrap"
  }
}

module "eks_cluster" {
  source               = "../."
  environment          = var.environment
  name                 = var.name
  namespace            = var.namespace
  desired_size         = var.desired_size
  instance_types       = var.instance_types
  kubernetes_namespace = var.kubernetes_namespace
  create_node_group    = true
  max_size             = var.max_size
  min_size             = var.min_size
  subnet_ids           = data.aws_subnets.private.ids
  region               = var.region
  //  route_53_zone                             = var.route_53_zone
  vpc_id                    = data.aws_vpc.vpc.id
  enabled                   = true
  kubernetes_version        = var.kubernetes_version
  apply_config_map_aws_auth = true
  kube_data_auth_enabled    = true
  kube_exec_auth_enabled    = true
  csi_driver_enabled        = var.csi_driver_enabled
  map_additional_iam_roles  = var.map_additional_iam_roles
  allowed_security_groups   = concat(data.aws_security_groups.eks_sg.ids, data.aws_security_groups.db_sg.ids)
}

data "aws_route53_zone" "default_domain" {
  name = var.route_53_zone
}

module "acm_request_certificate" {
  source                            = "cloudposse/acm-request-certificate/aws"
  version                           = "0.15.1"
  domain_name                       = var.route_53_zone
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = ["*.${var.route_53_zone}"]
  depends_on                        = [data.aws_route53_zone.default_domain]
}


module "ingress" {
  source               = "../ingress"
  certificate_arn      = module.acm_request_certificate.arn
  cluster_name         = module.eks_cluster.eks_cluster_id
  health_check_domains = var.health_check_domains
  route_53_zone_id     = data.aws_route53_zone.default_domain.zone_id
  depends_on           = [module.eks_cluster]
}
