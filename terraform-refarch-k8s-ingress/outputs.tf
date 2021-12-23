output "default_service_name" {
  value = try(kubernetes_service.default.metadata.0.name, null)
}

output "default_ingress_status" {
  value = kubernetes_ingress.default[0].status
}
