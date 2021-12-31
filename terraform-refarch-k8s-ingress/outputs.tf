output "default_service_name" {
  value = try(kubernetes_service.default.metadata.0.name, null)
}

output "default_ingress_hostname" {
  value = local.default_alb_hostname
}
