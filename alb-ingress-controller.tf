// TODO: create standalone module
/*
resource "kubernetes_namespace" "alb_namespace" {
  depends_on = [module.eks_cluster]
  count      = var.enabled ? 1 : 0

  metadata {
    name = "alb-ingress-controller"
  }
}


### iam ###
# Policy
data "aws_iam_policy_document" "alb_ingress" {
  depends_on = [module.eks_cluster]
  count      = var.enabled ? 1 : 0

  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }


  statement {
    actions = [
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "tag:GetResources",
      "tag:TagResources"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "waf:GetWebACL"
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "alb_ingress" {
  depends_on  = [module.eks_cluster]
  count       = var.enabled ? 1 : 0
  name        = "${local.cluster_name}-alb-ingress"
  path        = "/"
  description = "Policy for alb-ingress service"

  policy = data.aws_iam_policy_document.alb_ingress[0].json
  tags   = var.tags
}

# Role
data "aws_iam_policy_document" "alb_ingress_assume" {
  depends_on = [module.eks_cluster]
  count      = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks_cluster.eks_cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks_cluster.eks_cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${kubernetes_namespace.alb_namespace[0].metadata[0].name}:${local.cluster_name}-alb-ingress"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "alb_ingress" {
  depends_on         = [module.eks_cluster]
  count              = var.enabled ? 1 : 0
  name               = "${local.cluster_name}-alb-ingress"
  assume_role_policy = data.aws_iam_policy_document.alb_ingress_assume[0].json


}

resource "aws_iam_role_policy_attachment" "alb_ingress" {
  depends_on = [module.eks_cluster]
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.alb_ingress[0].name
  policy_arn = aws_iam_policy.alb_ingress[0].arn

}

resource "helm_release" "alb_ingress" {
  depends_on = [module.eks_cluster]
  count      = var.enabled ? 1 : 0
  name       = var.alb_ingress_helm_release_name
  repository = var.alb_ingress_helm_repo_url
  chart      = var.alb_ingress_helm_chart_name
  namespace  = kubernetes_namespace.alb_namespace[0].metadata[0].name
  version    = var.alb_ingress_helm_chart_version

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress[0].arn
  }

  dynamic "set" {
    for_each = local.ingress_settings

    content {
      name  = set.key
      value = set.value
    }
  }
}

# TODO: inject annotations?
# TODO: clean up
# TODO: S3 access logs
locals {
  #  annotations = merge(var.tags, var.annotations)
  annotations = merge(var.tags)
  load_balancer_attributes = {
    # Information about a load balancer attribute.

    # The following attribute is supported by all load balancers:
    #    delete_protection_enabled = "deletion_protection.enabled=${var.deletion_protection}"
    delete_protection_enabled = "deletion_protection.enabled=false"

    #    access_logs_s3_enabled = "access_logs.s3.enabled=false"
    #    access_logs_s3_bucket = "access_logs.s3.bucket=${var.logs_s3_bucket_name}"
    #    access_logs_s3_prefix = "access_logs.s3.prefix=${var.logs_s3_prefix}"

    alb_idle_timeout               = "idle_timeout.timeout_seconds=60"
    alb_desync_mitigation_mode     = "routing.http.desync_mitigation_mode=defensive"
    alb_drop_invalid_header_fields = "routing.http.drop_invalid_header_fields.enabled=true"
    alb_http_enabled               = "routing.http2.enabled=true"
    alb_waf_fail_open_enabled      = "waf.fail_open.enabled=false"
  }
  ssl_redirect = jsonencode({
    Type : "redirect",
    RedirectConfig : {
      Protocol : "HTTPS",
      Port : 443,
      StatusCode : "HTTP_301"
    }
  })
}

resource "time_sleep" "helm_ingress_sleep" {
  depends_on = [
    helm_release.alb_ingress
  ]
  create_duration = "75s"
}
*/

// TODO: clean up and pull from variables
#resource "kubernetes_ingress" "default_ingress" {
#  depends_on = [
#    time_sleep.helm_ingress_sleep
#  ]
#  lifecycle {
#    prevent_destroy = false
#  }
#  metadata {
#    name      = "default-ingress"
#    namespace = kubernetes_namespace.alb_namespace[0].metadata[0].name
#    annotations = {
#      "kubernetes.io/ingress.class"                        = "alb"
#      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
#      "alb.ingress.kubernetes.io/target-type"              = "ip"
#      "alb.ingress.kubernetes.io/load-balancer-attributes" = join(",", values(local.load_balancer_attributes))
#      "alb.ingress.kubernetes.io/actions.ssl-redirect"     = local.ssl_redirect
#      "alb.ingress.kubernetes.io/group.name"               = "ingress-group"
#      "alb.ingress.kubernetes.io/group.order"              = "1"
#      "alb.ingress.kubernetes.io/subnets"                  = join(",", data.aws_subnet_ids.public.ids)
#      "alb.ingress.kubernetes.io/ssl-policy"               = "ELBSecurityPolicy-TLS-1-2-2017-01"
#      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
#        { HTTP : 80 }
#      ])
#    }
#  }
#  spec {
#    rule {
#      http {
#        path {
#          path = "/*"
#          backend {
#            service_name = "ssl-redirect"
#            service_port = "use-annotation"
#          }
#        }
#      }
#    }
#  }
#}

/*
module "alb_ingress_eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.26.0"

  subnet_ids                 = data.aws_subnet_ids.private.ids
  cluster_name               = module.eks_cluster.eks_cluster_id
  instance_types             = var.instance_types
  desired_size               = var.desired_size
  min_size                   = var.min_size
  max_size                   = var.max_size
  kubernetes_labels          = var.kubernetes_labels
  cluster_autoscaler_enabled = true
  # Prevent the node groups from being created before the Kubernetes aws-auth ConfigMap
  module_depends_on = module.eks_cluster.kubernetes_config_map_id

  context               = module.this.context
  node_role_policy_arns = [aws_iam_policy.alb_ingress[0].arn]
  namespace             = kubernetes_namespace.alb_namespace[0].metadata[0].name
}
*/

module "alb_ingress_controller" {
  source   = "../terraform-aws-ref-arch-alb-ingress-controller"
#  source   = "git::git@github.com:sourcefuse/terraform-aws-ref-arch-alb-ingress-controller.git?ref=feature/tf-module-alb-ingress-controller"
  context  = module.this.context
  vpc_name = var.vpc_name
  name     = "refarch-${terraform.workspace}"

  kubernetes_config_map_id = module.eks_cluster.kubernetes_config_map_id

  eks_cluster_name            = module.eks_cluster.eks_cluster_id
  eks_node_group_desired_size = 2
  eks_node_group_max_size     = 25
  eks_node_group_min_size     = 2

  eks_node_group_kubernetes_labels      = var.kubernetes_labels
  eks_node_group_instance_types         = ["t3.medium"]
  eks_node_group_subnet_ids             = data.aws_subnet_ids.private.ids
  eks_cluster_identity_oidc_issuer      = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_identity_oidc_issuer_arns = [module.eks_cluster.eks_cluster_identity_oidc_issuer_arn]

  tags = {
    EKSCluster = module.eks_cluster.eks_cluster_id
  }
}
