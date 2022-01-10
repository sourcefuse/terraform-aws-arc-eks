// TODO: encapsulate into module
// TODO: run on fargate
locals {
  boilerplate_ui_namespace    = "boilerplate-ui"
  boilerplate_ui_docker_image = "sourcefuse/react-boilerplate-ui:latest"
}

resource "kubernetes_namespace" "boilerplate_ui" {
  metadata {
    annotations = {
      name = local.boilerplate_ui_namespace
    }

    labels = {
      name = local.boilerplate_ui_namespace
    }

    name = local.boilerplate_ui_namespace
  }
}


module "boilerplate_ui_applications" {
  source          = "git@github.com:sourcefuse/terraform-k8s-app.git"
  for_each        = local.boilerplate_k8s_apps
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
  boilerplate_k8s_apps = {
    ui = {
      app_label             = "boilerplate-ui"
      container_image       = local.boilerplate_ui_docker_image
      container_name        = "boilerplate-ui"
      container_port        = 80
      deployment_name       = "boilerplate-ui"
      namespace_name        = local.boilerplate_ui_namespace
      port                  = 80
      port_name             = "80"
      protocol              = "TCP"
      service_name          = "boilerplate-ui-svc"
      target_port           = 80
      replica_count         = 1
      environment_variables = []
    }
  }
}

module "k8s_ingress_boilerplate_ui" {
  source = "./terraform-refarch-k8s-ingress"

  ## shared
  namespace = local.boilerplate_ui_namespace
  #  default_ingress_name = "boilerplate-ui-ing"
  #  default_service_name = "boilerplate-ui-svc"
  enable_internal_alb = false

  ## service
  default_service_annotations = {
    "alb.ingress.kubernetes.io/group.name" = local.shared_ingress_group_name
  }

  default_service_ports = [
    {
      name     = "boilerplate-ui-port-80"
      port     = 80
      protocol = "TCP"
    }
  ]

  ## ingress
  default_ingress_alias = "boilerplate-ui.sfrefarch.com"
  default_ingress_rules = [
    {
      path         = "/*"
      service_port = "80"
    }
  ]

  // TODO - make some of these default (set in the module)
  default_ingress_annotations = {
    "kubernetes.io/ingress.class"                    = "alb"
    "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
    "alb.ingress.kubernetes.io/group.name"           = local.shared_ingress_group_name
    "alb.ingress.kubernetes.io/target-type"          = "ip"
    "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
    "alb.ingress.kubernetes.io/certificate-arn"      = module.acm_request_certificate.arn
    "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
    "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
    "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
    "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }

  ## route 53
  default_parent_route53_zone_id = data.aws_route53_zone.ref_arch_domain.id
}
