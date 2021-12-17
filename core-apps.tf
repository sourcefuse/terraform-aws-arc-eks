resource "kubectl_manifest" "manifests" {
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value

  depends_on = [
    module.alb_ingress_controller
  ]
}

// TODO - remove to different file
module "k8s_ingress" {
  source = "./terraform-refarch-k8s-ingress"

  namespace            = "game-2048-2"
  default_ingress_name = "ingress-tss-2048"  // TODO - remove tss
  enable_internal_alb  = false

  default_ingress_annotations = {
    "kubernetes.io/ingress.class"           = "alb"
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }
}
