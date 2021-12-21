## 2048 game
module "k8s_ingress_2048" {
  source   = "./terraform-refarch-k8s-ingress"

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
  source   = "./terraform-refarch-k8s-ingress"

#  default_name         = "health-check-tss"
  namespace            = "health-check"
#  default_service_type = "ClusterIP"
  enable_internal_alb  = false

  default_service_selector = {
    app = "nginx"
  }

  default_annotations = {
    "kubernetes.io/ingress.class"           = "alb"
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }

  default_service_ports = [
    {
      name        = "health-check-port-80"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  ]
}
