terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}


locals {
  boilerplate_ui_namespace    = "boilerplate-ui"
  boilerplate_ui_docker_image = "sourcefuse/react-boilerplate-ui:0.1.0"
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

  lifecycle {
    create_before_destroy = true
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

// TODO: refactor
data "kubectl_path_documents" "docs" {
  pattern = "./boilerplate-ui/manifests/*.yaml"
}

resource "kubectl_manifest" "manifests" {
  for_each  = data.kubectl_path_documents.docs.manifests
  yaml_body = each.value
}
