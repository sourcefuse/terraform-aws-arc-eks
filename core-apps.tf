resource "kubectl_manifest" "manifests" {
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value
}

module "boilerplate_ui" {
  source = "./boilerplate-ui"
}
