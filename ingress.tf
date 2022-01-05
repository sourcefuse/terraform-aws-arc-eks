// TODO - change to a shared alb
## shared ingress
variable "ingress_namespace" {
  default = "refarch-shared-ingress"
}

locals {
  shared_ingress_group_name = "${var.ingress_namespace}-group"
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = var.ingress_namespace

    annotations = {
      name = var.ingress_namespace
    }

    labels = {
      name = var.ingress_namespace
    }
  }
}

module "k8s_ingress" {
  source = "./terraform-refarch-k8s-ingress"

  ## shared
  namespace            = var.ingress_namespace
  default_ingress_name = "${var.ingress_namespace}-ing"
  default_service_name = "${var.ingress_namespace}-svc"
  enable_internal_alb  = false

  ## service
  default_service_annotations = {
    "alb.ingress.kubernetes.io/group.name" = local.shared_ingress_group_name
  }

  default_service_ports = [
    {
      port     = 80
    }
  ]

  ## ingress
  default_ingress_rules = [
    {
      path         = "/*"
      service_port = "80"
    }
  ]

  default_ingress_annotations = {
    "kubernetes.io/ingress.class"                    = "alb"
    "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
    "alb.ingress.kubernetes.io/group.name"           = local.shared_ingress_group_name
  }
}

## health checks
module "k8s_ingress_health_check" {
  source = "./terraform-refarch-k8s-ingress"

  ## shared
  namespace           = "health-check"
  enable_internal_alb = false

  ## service
  default_service_annotations = {
    "alb.ingress.kubernetes.io/group.name" = local.shared_ingress_group_name
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
    "alb.ingress.kubernetes.io/group.name"           = local.shared_ingress_group_name
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
