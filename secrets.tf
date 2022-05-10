// TODO - remove hardcoded values
resource "helm_release" "csi_driver" {
  count = var.csi_driver_enabled == true ? 1 : 0

  name       = "secrets-store-csi-driver"
  namespace  = "kube-system"
  chart      = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  version    = "0.2.0"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}
