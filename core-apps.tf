resource "kubectl_manifest" "manifests" {
  depends_on = [
    module.alb_ingress_controller
  ]
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value
}
