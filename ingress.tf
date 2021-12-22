## 2048 game
module "k8s_ingress_2048" {
  source = "./terraform-refarch-k8s-ingress"

  default_name         = "ingress-2048"
  namespace            = "game-2048-2"
  default_service_type = "NodePort"
  enable_internal_alb  = false

  default_service_selector = {
    "app.kubernetes.io/name" = "app-2048"
  }

  default_annotations = {
    "kubernetes.io/ingress.class"           = "alb"
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }

  default_service_ports = [
    {
      name        = "ingress-2048-port-80"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  ]
}

## health checks
module "k8s_ingress_health_check" {
  source = "./terraform-refarch-k8s-ingress"

  namespace           = "health-check"
  enable_internal_alb = false

  default_service_selector = {
    app = "nginx"
  }

  default_annotations = {
    "kubernetes.io/ingress.class"            = "alb"
    "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
    "alb.ingress.kubernetes.io/target-type"  = "ip"
    "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"  = "arn:aws:acm:us-east-1:757583164619:certificate/e3f2a631-3c3c-4185-a816-38e8b8c66b10" // module.acm_request_certificate.arn
    "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "health-check-port-443"
    "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
  }

  default_service_ports = [
    {
      name        = "health-check-port-443"
      port        = 443
      target_port = 80
      protocol    = "TCP"
    }
  ]
}
