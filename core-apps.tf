resource "kubectl_manifest" "manifests" {
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value

  depends_on = [
    module.alb_ingress_controller
  ]
}

// TODO - move to different file
module "k8s_ingress" {
  source = "./terraform-refarch-k8s-ingress"

  namespace            = "game-2048-2"
#  default_name = "ingress-tss-2048-2" // TODO - remove tss
  default_service_type = "NodePort"
  enable_internal_alb  = false

  default_annotations = {
    "kubernetes.io/ingress.class"           = "alb"
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }

  default_service_ports = [
    {
      name        = "ingress-tss-2048-2-port-80"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  ]
}
