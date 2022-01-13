// TODO: encapsulate into module
// TODO: run on fargate
variable "namespace_name" {
  type        = string
  default     = "health-check"
  description = "Namespace name"
}


resource "kubernetes_namespace" "health_check" {
  metadata {
    annotations = {
      name = var.namespace_name
    }

    labels = {
      name = var.namespace_name
    }

    name = var.namespace_name
  }
}

variable "nginx_image" {
  default     = "nginx:alpine"
  description = "Image version for Nginx"
  type        = string
}


module "core_apps" {
  source          = "git@github.com:sourcefuse/terraform-k8s-app.git"
  for_each        = local.k8s_apps
  app_label       = each.value.app_label
  container_image = each.value.container_image
  container_name  = each.value.container_name
  container_port  = each.value.container_port
  deployment_name = each.value.deployment_name
  namespace_name  = each.value.namespace_name
  port            = each.value.port
  port_name       = each.value.port_name
  protocol        = each.value.protocol
  service_name    = each.value.service_name
  target_port     = each.value.target_port
  replica_count   = each.value.replica_count

  ## pvc
  persistent_volume_claim_enable           = try(each.value.persistent_volume_claim_enable, false)
  persistent_volume_claim_name             = try(each.value.persistent_volume_claim_name, null)
  persistent_volume_claim_labels           = try(each.value.persistent_volume_claim_labels, {})
  persistent_volume_claim_namespace        = try(each.value.persistent_volume_claim_namespace, null)
  persistent_volume_claim_resource_request = try(each.value.persistent_volume_claim_resource_request, {})

  environment_variables = each.value.environment_variables
}

locals {
  health_check_service_host = "health-check-svc.${kubernetes_namespace.health_check.metadata[0].name}.svc.cluster.local"
  k8s_apps = {
    health_check_application = {
      app_label       = "nginx"
      container_image = var.nginx_image
      container_name  = "nginx"
      container_port  = 80
      deployment_name = "nginx"
      namespace_name  = "ingress-nginx"
      #      namespace_name        = kubernetes_namespace.health_check.metadata[0].name
      port                  = 80
      port_name             = "80"
      protocol              = "TCP"
      service_name          = "health-check-svc"
      target_port           = 80
      replica_count         = 1
      environment_variables = []
    }
  }
}
