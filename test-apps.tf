#// TODO: replace with ALB ingress controller
#resource "helm_release" "nginx_ingress" {
#  name = "nginx-ingress-controller"
#
#  repository = "https://charts.bitnami.com/bitnami"
#  chart      = "nginx-ingress-controller"
#
#  set {
#    name  = "service.type"
#    value = "ClusterIP"
#  }
#}

data "kubectl_path_documents" "docs" {
  pattern = "./manifests/*.yaml"
}


resource "kubectl_manifest" "manifests" {
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value
}
