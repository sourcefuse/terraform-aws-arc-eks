output "default_service_name" {
  value = try(kubernetes_service.default.metadata.0.name, null)
}

output "default_ingress_hostname" {
  value = try(kubernetes_ingress.default[0].status[0]["load_balancer"][0]["ingress"][0]["hostname"], null)
}
