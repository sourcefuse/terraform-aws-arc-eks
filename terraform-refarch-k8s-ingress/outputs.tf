output "default_service_name" {
  value = try(kubernetes_service.default.metadata.0.name, null)
}

output "default_alb_hostname" {
  value = local.default_alb_hostname
}

output "default_alb_shortname" {
  value = local.default_alb_shortname
}

output "debug" {
  value = kubernetes_ingress.default
}
