resource "kubernetes_ingress" "default_ingress" {
  dynamic "metadata" {
    for_each =  local.default_ingress_metadata

    content {
      name        = lookup(metadata.value, "name", null)
      namespace   = lookup(metadata.value, "namespace", "kube-system")
      annotations = lookup(metadata.value, "annotations", {})
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"

          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
      }
    }
  }

  lifecycle {
    #Before you delete the alb controller make sure you set to false "deletion_protection" property on the aws load balancer (you can change the variable and then terraform apply).
    #Also Make sure that there isn't any ingress resource using the alb controller!
    #Otherwise terraform (k8s) won't be able to delete the alb and its resources.
    prevent_destroy = true
  }
}

resource "kubernetes_ingress" "private_ingress" {
  count = var.enable_internal_alb == true ? 1 : 0

  dynamic "metadata" {
    for_each =  local.private_ingress_metadata

    content {
      name        = lookup(metadata.value, "name", null)
      namespace   = lookup(metadata.value, "namespace", "kube-system")
      annotations = lookup(metadata.value, "annotations", {})
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"

          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
      }
    }
  }

  lifecycle {
    #Before you delete the alb controller make sure you set to false "deletion_protection" property on the aws load balancer (you can change the variable and then terraform apply).
    #Also Make sure that there isn't any ingress resource using the alb controller!
    #Otherwise terraform (k8s) won't be able to delete the alb and its resources.
    prevent_destroy = true
  }
}
