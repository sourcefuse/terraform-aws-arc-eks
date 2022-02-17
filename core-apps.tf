// TODO: make individual modules
resource "kubectl_manifest" "core_apps" {
  for_each         = data.kubectl_path_documents.docs.manifests
  yaml_body        = each.value
  wait_for_rollout = true
}
