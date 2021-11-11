#######################################################
## data lookups
#######################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

#######################################################
## kubernetes / helm
#######################################################
resource "kubernetes_namespace" "alb" {
  metadata {
    name = var.eks_namespace
  }
}


#######################################################
## iam
#######################################################
## policy
data "aws_iam_policy_document" "alb_ingress" {
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
  name        = "${var.name}-alb-ingress-policy"
  path        = "/"
  description = "Policy for alb ingress service"
  policy      = data.aws_iam_policy_document.alb_ingress.json

  tags = merge(local.tags, tomap({
    Name = "${var.name}-alb-ingress-policy"
  }))
}

## role
data "aws_iam_policy_document" "alb_ingress_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = var.eks_cluster_identity_oidc_issuer_arns
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${kubernetes_namespace.alb.metadata[0].name}:${var.eks_cluster_name}-alb-ingress"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "alb_ingress" {
  name               = "${var.name}-alb-ingress-role"
  assume_role_policy = data.aws_iam_policy_document.alb_ingress_assume.json

  tags = merge(local.tags, tomap({
    Name = "${var.name}-alb-ingress-role"
  }))
}

resource "aws_iam_role_policy_attachment" "alb_ingress" {
  role       = aws_iam_role.alb_ingress.name
  policy_arn = aws_iam_policy.alb_ingress.arn
}

#######################################################
## helm
#######################################################
resource "helm_release" "alb_ingress" {
  name       = var.alb_ingress_helm_release_name
  repository = var.alb_ingress_helm_repo_url
  chart      = var.alb_ingress_helm_chart_name
  namespace  = kubernetes_namespace.alb.metadata[0].name
  version    = var.alb_ingress_helm_chart_version

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
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
    name  = "rbac.serviceAccountAnnotations.eks.amazonaws.com/role-arn"
    value = aws_iam_role.alb_ingress.arn
  }

  dynamic "set" {
    for_each = local.ingress_settings

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "time_sleep" "helm_ingress_sleep" {
  create_duration = "75s"
}

// TODO: clean up and pull from variables
#resource "kubernetes_ingress" "default" {
#  metadata {
#    name      = "default-ingress"
#    namespace = kubernetes_namespace.alb.metadata[0].name
#
#    annotations = {
#      "kubernetes.io/ingress.class"                        = "alb"
#      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
#      "alb.ingress.kubernetes.io/target-type"              = "ip"
#      "alb.ingress.kubernetes.io/load-balancer-attributes" = join(",", values(local.load_balancer_attributes))
#      "alb.ingress.kubernetes.io/actions.ssl-redirect"     = local.ssl_redirect
#      "alb.ingress.kubernetes.io/group.name"               = "ingress-group"
#      "alb.ingress.kubernetes.io/group.order"              = "1"
#      "alb.ingress.kubernetes.io/subnets"                  = join(",", var.eks_ingress_public_subnet_ids)
#      "alb.ingress.kubernetes.io/ssl-policy"               = "ELBSecurityPolicy-TLS-1-2-2017-01"
#      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
#        { HTTP : 80 }
#      ])
#    }
#  }
#
#  spec {
#    rule {
#      http {
#        path {
#          path = "/*"
#
#          backend {
#            service_name = "ssl-redirect"
#            service_port = "use-annotation"
#          }
#        }
#      }
#    }
#  }
#
#  lifecycle {
#    prevent_destroy = false
#  }
#}

#/*
module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "0.26.0"

  subnet_ids                 = var.eks_node_group_private_subnet_ids
  cluster_name               = var.eks_cluster_name
  instance_types             = var.eks_node_group_instance_types
  desired_size               = var.eks_node_group_desired_size
  min_size                   = var.eks_node_group_min_size
  max_size                   = var.eks_node_group_max_size
  kubernetes_labels          = var.eks_node_group_kubernetes_labels
  create_before_destroy      = true  // TODO - make this a var since this is destructive
  cluster_autoscaler_enabled = true

  namespace             = "default"  # kubernetes_namespace.alb.metadata[0].name
  node_role_policy_arns = [aws_iam_policy.alb_ingress.arn]
  context               = var.context

  // TODO - remove hardcoded ids and make a new var
  associated_security_group_ids = var.eks_node_group_associated_security_group_ids

  # Prevent the node groups from being created before the Kubernetes aws-auth ConfigMap
  module_depends_on = var.kubernetes_config_map_id

  tags = local.tags

  additional_tag_map = tomap({
    Name                                    = "${kubernetes_namespace.alb.metadata[0].name}-dynamic-worker"
    "kubernetes.io/ingress.class"           = "alb"
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  })
}
#*/
