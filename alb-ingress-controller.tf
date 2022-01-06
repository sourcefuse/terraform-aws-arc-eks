module "alb_ingress_controller" {
  source = "./terraform-aws-ref-arch-alb-ingress-controller"
  #  source   = "git::git@github.com:sourcefuse/terraform-aws-ref-arch-alb-ingress-controller.git?ref=feature/tf-module-alb-ingress-controller"
  context  = module.this.context
  vpc_name = var.vpc_name
  name     = "refarch-${terraform.workspace}"

  kubernetes_config_map_id    = module.eks_cluster.kubernetes_config_map_id
  eks_cluster_name            = module.eks_cluster.eks_cluster_id
  eks_node_group_desired_size = 2
  eks_node_group_max_size     = 25
  eks_node_group_min_size     = 2

  eks_node_group_kubernetes_labels  = var.kubernetes_labels
  eks_node_group_instance_types     = ["t3.medium"]
  eks_node_group_private_subnet_ids = data.aws_subnet_ids.private.ids
  eks_ingress_public_subnet_ids     = data.aws_subnet_ids.public.ids

  eks_node_group_associated_security_group_ids = [module.eks_cluster.security_group_id]

  eks_cluster_identity_oidc_issuer      = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_identity_oidc_issuer_arns = [module.eks_cluster.eks_cluster_identity_oidc_issuer_arn]

  tags = merge(module.tags.tags, tomap({
    "kubernetes.io/cluster/${module.label.id}" = "shared"
  }))
}

data "aws_route53_zone" "ref_arch_domain" {
  name = "sfrefarch.com"
}

// TODO: make variables
module "acm_request_certificate" {
  source                            = "cloudposse/acm-request-certificate/aws"
  version                           = "0.15.1"
  domain_name                       = "sfrefarch.com"
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = ["*.sfrefarch.com"]
  depends_on                        = [data.aws_route53_zone.ref_arch_domain]

  tags = module.tags.tags
}
