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

// TODO: make variable or find better way to do this
resource "time_sleep" "nlb_provisioning_time" {
  create_duration = "120s"
}

resource "helm_release" "ingress_nginx" {

  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.23.0"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.certificate_arn
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "https"
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout"
    value = "60"
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "http"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = "Name=${var.cluster_name}"
    type  = "string"
  }

  set {
    name  = "controller.service.targetPorts.https"
    value = "http"
    type  = "string"
  }
}

resource "kubectl_manifest" "health_check_ingress" {
  yaml_body = templatefile("${path.module}/health-check-ingress.yaml", {
    health_check_domain = var.health_check_domains[0]
  })
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
