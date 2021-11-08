// TODO: turn into standard module
// TODO: tighten security
// TODO: interpolate manifests where needed, convert to helm, or use native k8s app module
data "kubectl_path_documents" "docs" {
  pattern = "./manifests/*.yaml"
}


resource "kubectl_manifest" "manifests" {
  depends_on = [
    module.alb_ingress_controller
  ]
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value
}
