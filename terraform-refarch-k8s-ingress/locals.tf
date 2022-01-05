locals {
  // TODO - remove or update variable inputs.
#  default_ingress_hostname = try(kubernetes_ingress.default[0].status[0]["load_balancer"][0]["ingress"][0]["hostname"], null)
#  default_alb_hostname     = try(substr(split(".", local.default_ingress_hostname)[0], 0, 32), "")
#  default_alb_shortname    = try(regex("(.*)-.*", local.default_alb_hostname)[0], "")

  default_ingress_hostname = kubernetes_ingress.default[0].status[0]["load_balancer"][0]["ingress"][0]["hostname"]
#  default_alb_hostname     = substr(split(".", local.default_ingress_hostname)[0], 0, 32)
  default_alb_hostname     = split(".", local.default_ingress_hostname)[0]
  default_alb_shortname    = trimsuffix(regex("(.*-)", local.default_alb_hostname)[0], "-")
  default_alb_aliases      = concat([var.default_ingress_alias], var.default_alb_additional_aliases)
}
