##########################################################################
## services
##########################################################################
resource "kubernetes_service" "default" {
  wait_for_load_balancer = true

  metadata {
    name          = var.default_service_name
    generate_name = true ? var.default_service_name == null : false
    namespace     = var.namespace
    annotations   = var.default_service_annotations
    labels        = var.default_labels
  }

  spec {
    type     = var.default_service_type
    selector = var.default_service_selector

    load_balancer_source_ranges = var.default_service_load_balancer_source_ranges

    // TODO - SRA-175 - add support for the following
    /*
    cluster_ip
    external_ips
    external_name
    external_traffic_policy
    load_balancer_ip
    publish_not_ready_addresses
    selector
    session_affinity
    health_check_node_port
    */

    dynamic "port" {
      for_each = var.default_service_ports

      content {
        name        = try(port.value.name, length(var.default_service_ports) > 1 ? "Port_${port.value.port}" : "")
        port        = port.value.port
        node_port   = try(port.value.node_port, null)
        target_port = try(port.value.target_port, port.value.port)
        protocol    = try(port.value.protocol, "TCP")
      }
    }
  }
}

##########################################################################
## ingress
##########################################################################
## default ingress
resource "kubernetes_ingress" "default" {
  count = kubernetes_service.default.spec.0.type == "LoadBalancer" ? 0 : 1

  metadata {
    name          = var.default_ingress_name
    generate_name = true ? var.default_ingress_name == null : false
    namespace     = var.namespace
    annotations   = var.default_ingress_annotations
    labels        = var.default_labels
  }

  spec {
    dynamic "rule" {
      for_each = var.default_ingress_rules  // kubernetes_service.default.spec

      content {
        host = var.default_ingress_host

        http {
          path {
            path = try(rule.value.path, "/*")

            backend {
              service_name = try(rule.value.service_name, kubernetes_service.default.metadata.0.name)
              service_port = tostring(rule.value.service_port)
            }
          }
        }
      }
    }
  }

  lifecycle {
    # Before you delete the alb controller make sure you set to false "deletion_protection"
    # property on the aws load balancer (you can change the variable and then terraform apply).
    # Also Make sure that there isn't any ingress resource using the alb controller!
    # Otherwise terraform (k8s) won't be able to delete the alb and its resources.
    prevent_destroy = false // TODO - set to true
  }
}

/*
## private ingress
resource "kubernetes_ingress" "private" {
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
*/
