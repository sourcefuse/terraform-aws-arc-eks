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

resource "kubectl_manifest" "manifests" {
  depends_on = [
    time_sleep.helm_ingress_sleep
  ]
  for_each  = fileset(path.module, "manifests/*.yaml")
  yaml_body = file(each.value)
}
