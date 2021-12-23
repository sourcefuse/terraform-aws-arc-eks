## health checks
module "k8s_ingress_health_check" {
  source = "./terraform-refarch-k8s-ingress"

  namespace           = "health-check"
  enable_internal_alb = false

  default_service_selector = {
    app = "nginx"
  }

  default_ingress_annotations = {
    "kubernetes.io/ingress.class"                = "alb"
    "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"      = "ip"
    "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
    "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
    "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:us-east-1:757583164619:certificate/e3f2a631-3c3c-4185-a816-38e8b8c66b10" // module.acm_request_certificate.arn
    "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
  }

  default_service_ports = [
    {
      name     = "health-check-port-80"
      port     = 80
      protocol = "TCP"
    }
  ]

  default_ingress_rules = [
    {
      path         = "/*"
      service_name = module.k8s_ingress_health_check.default_service_name
      service_port = "80"
    }
  ]
}

// TODO - dynamically pass in alias zone id from kubernetes_ingress
/*
resource "aws_route53_record" "hc" {
  zone_id = data.aws_route53_zone.ref_arch_domain.id
  name    = data.aws_route53_zone.ref_arch_domain.name
  type    = "A"

  alias {
    name                   = "healthcheck.sfrefarch.com"
    zone_id                = data.aws_route53_zone.ref_arch_domain.id
    evaluate_target_health = true
  }
}

output "status" {
  value = module.k8s_ingress_health_check.default_ingress_status
}
*/
