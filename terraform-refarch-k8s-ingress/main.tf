resource "kubernetes_ingress" "default_ingress" {
  metadata {
    name        = var.default_ingress_name
    namespace   = var.namespace
    annotations = var.private_ingress_annotations
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

  metadata {
    name        = var.private_ingress_name
    namespace   = var.namespace
    annotations = var.private_ingress_annotations
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
