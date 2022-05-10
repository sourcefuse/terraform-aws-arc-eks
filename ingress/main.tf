terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "kubernetes_namespace" "ingress_namespace" {
  metadata {
    annotations = {
      name = var.ingress_namespace_name
    }

    labels = {
      name                         = var.ingress_namespace_name
      "app.kubernetes.io/name"     = var.ingress_namespace_name
      "app.kubernetes.io/instance" = var.ingress_namespace_name
    }

    name = var.ingress_namespace_name
  }
}

module "health_check" {
  source                                  = "git@github.com:sourcefuse/terraform-k8s-app.git?ref=0.1.1"
  app_label                               = "health-check"
  container_image                         = var.health_check_image
  container_name                          = "health-check"
  container_port                          = 80
  deployment_name                         = "health-check"
  namespace_name                          = var.ingress_namespace_name
  port                                    = 80
  port_name                               = "80"
  protocol                                = "TCP"
  service_name                            = "health-check-svc"
  target_port                             = 80
  replica_count                           = 1
  environment_variables                   = []
  persistent_volume_secret_provider_class = ""
  config_map_binary_data                  = {}
  config_map_data                         = {}
  config_map_name                         = ""
  persistent_volume_claim_enable          = false
  persistent_volume_enable                = false
  persistent_volume_name                  = ""
}

// TODO: eliminate sleep
data "aws_lb" "eks_nlb" {
  tags = {
    Name = var.cluster_name
  }

  depends_on = [time_sleep.nlb_provisioning_time]
}

resource "time_sleep" "nlb_provisioning_time" {
  create_duration = "60s"
}

// TODO: collect rest of values to interpolate
// TODO: fix hacks below with Helm chart introduction or reimplement in native TF
// a separate file is needed to deal with conflicting interpolation tokens
resource "kubectl_manifest" "ingress_controller_service" {
  yaml_body = templatefile("${path.module}/ingress-nginx/controller-service.yaml", {
    load_balancer_name = var.cluster_name
    certificate_arn    = var.certificate_arn
  })
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_controller_serviceaccount" {
  yaml_body  = file("${path.module}/ingress-nginx/controller-serviceaccount.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_controller_configmap" {
  yaml_body  = file("${path.module}/ingress-nginx/controller-configmap.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_clusterrole" {
  yaml_body  = file("${path.module}/ingress-nginx/clusterrole.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_clusterrolebinding" {
  yaml_body  = file("${path.module}/ingress-nginx/clusterrolebinding.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_controller_role" {
  yaml_body  = file("${path.module}/ingress-nginx/controller-role.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_controller_rolebinding" {
  yaml_body  = file("${path.module}/ingress-nginx/controller-rolebinding.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_controller_servicewebhook" {
  yaml_body  = file("${path.module}/ingress-nginx/controller-service-webhook.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_controller_deployment" {
  yaml_body  = file("${path.module}/ingress-nginx/controller-deployment.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_validating_webhook" {
  yaml_body  = file("${path.module}/ingress-nginx/validating-webhook.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_jobpatch_service_account" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-serviceaccount.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]

}
resource "kubectl_manifest" "ingress_nginx_jobpatch_clusterrolebinding" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-clusterrolebinding.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_jobpatch_clusterrole" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-clusterrole.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_jobpatch_role" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-role.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}


resource "kubectl_manifest" "ingress_nginx_jobpatch_rolebinding" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-rolebinding.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_jobpatch_job_createsecret" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-job-createsecret.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "ingress_nginx_jobpatch_job_patchwebhook" {
  yaml_body  = file("${path.module}/ingress-nginx/job-patch-job-patchwebhook.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace]
}

resource "kubectl_manifest" "health_check_ingress" {
  yaml_body  = file("${path.module}/health-check-ingress.yaml")
  depends_on = [kubernetes_namespace.ingress_namespace, module.health_check]
}

resource "aws_route53_record" "app_domain_records" {
  zone_id  = var.route_53_zone_id
  for_each = toset(var.health_check_domains)

  name = each.value
  type = "A"

  alias {
    name                   = data.aws_lb.eks_nlb.dns_name
    zone_id                = data.aws_lb.eks_nlb.zone_id
    evaluate_target_health = false
  }

  lifecycle {
    create_before_destroy = false
  }
}
