
module "k8s_ingress" {
  source = "./terraform-refarch-k8s-ingress"

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
      name        = "ingress-2048-2-port-80"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  ]
}
