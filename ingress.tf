// TODO - change to a shared alb
## health checks
module "k8s_ingress_health_check" {
  source = "./terraform-refarch-k8s-ingress"

  ## shared
  namespace           = "health-check"
  enable_internal_alb = false

  ## service
  default_service_annotations = {
    "alb.ingress.kubernetes.io/group.name" = "ingress-group"
  }

  default_service_ports = [
    {
      name     = "health-check-port-80"
      port     = 80
      protocol = "TCP"
    }
  ]

  ## ingress
  default_ingress_alias = "healthcheck.sfrefarch.com"
  default_ingress_rules = [
    {
      path         = "/*"
      service_port = "80"
    }
  ]

  // TODO - make some of these default (set in the module)
  default_ingress_annotations = {
    "kubernetes.io/ingress.class"                    = "alb"
    "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
    "alb.ingress.kubernetes.io/group.name"           = "ingress-group"
    "alb.ingress.kubernetes.io/target-type"          = "ip"
    "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
    "alb.ingress.kubernetes.io/certificate-arn"      = module.acm_request_certificate.arn
    "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
    "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
    "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
    "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }

  ## route 53
  default_parent_route53_zone_id = data.aws_route53_zone.ref_arch_domain.id
}

// move this section to the terraform-refarch-k8s-ingress module
// --- START --- //
/*
locals {
  alb_hostname = substr(split(".", module.k8s_ingress_health_check.default_ingress_hostname)[0], 0, 32)
  alb_name = regex("(.*)-.*", local.alb_hostname)[0]
  route53_zone = "sfrefarch.com"  // TODO - move to variables
  healthcheck_dns_name = "healthcheck.${local.route53_zone}"
}

data "aws_lb" "healthcheck" {
  name = local.alb_name
}

module "alb_alias" {
  source = "git::https://github.com/cloudposse/terraform-aws-route53-alias?ref=0.12.1"

  parent_zone_id  = data.aws_route53_zone.ref_arch_domain.id
  target_dns_name = data.aws_lb.healthcheck.dns_name
  target_zone_id  = data.aws_lb.healthcheck.zone_id

  aliases = [
    local.healthcheck_dns_name
  ]
}
*/
// --- END --- //
