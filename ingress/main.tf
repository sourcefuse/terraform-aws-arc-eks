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
  source                = "git@github.com:sourcefuse/terraform-k8s-app.git"
  app_label             = "health-check"
  container_image       = var.health_check_image
  container_name        = "health-check"
  container_port        = 80
  deployment_name       = "health-check"
  namespace_name        = var.ingress_namespace_name
  port                  = 80
  port_name             = "80"
  protocol              = "TCP"
  service_name          = "health-check-svc"
  target_port           = 80
  replica_count         = 1
  environment_variables = []
}

// TODO: eliminate sleep
data "aws_lb" "eks_nlb" {
  tags = {
    Name = var.cluster_name
  }

  depends_on = [time_sleep.nlb_provisioning_timeout]
}

resource "time_sleep" "nlb_provisioning_timeout" {
  depends_on = [kubectl_manifest.ingress_controller, kubectl_manifest.ingress_controller_service]

  create_duration = "60s"
}

// TODO: collect rest of values to interpolate
// TODO: fix hacks below with Helm chart introduction or reimplement in native TF
// a separate file is needed to deal with conflicting interpolation tokens
resource "kubectl_manifest" "ingress_controller_service" {
  yaml_body = templatefile("${path.module}/controller-service.yaml", {
    load_balancer_name = var.cluster_name
    certificate_arn    = var.certificate_arn
  })
  depends_on = [kubernetes_namespace.ingress_namespace, module.health_check]
}


data "kubectl_path_documents" "ingress_nginx" {
  pattern = "${path.module}/ingress-nginx.yaml"
}

resource "kubectl_manifest" "ingress_controller" {
  for_each   = data.kubectl_path_documents.ingress_nginx.manifests
  yaml_body  = each.value
  depends_on = [kubernetes_namespace.ingress_namespace, module.health_check]
}

data "kubectl_path_documents" "health_check_ingress" {
  pattern = "${path.module}/health-check-ingress.yaml"
}


resource "kubectl_manifest" "health_check_ingress" {

  for_each   = data.kubectl_path_documents.health_check_ingress.manifests
  yaml_body  = each.value
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
