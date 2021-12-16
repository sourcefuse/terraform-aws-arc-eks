#######################################################
## data lookups
#######################################################
// TODO: pass VPC info in
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
resource "aws_iam_policy" "alb_ingress" {
  name        = "${var.name}-alb-ingress-policy"
  path        = "/"
  description = "Policy for alb ingress service"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
}
EOF

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

      // TODO: check below - concatenated name may be incorrect
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
  create_before_destroy      = var.eks_node_group_create_before_destroy
  cluster_autoscaler_enabled = var.eks_node_group_cluster_autoscaler_enabled

  namespace             = kubernetes_namespace.alb.metadata[0].name
  node_role_policy_arns = [aws_iam_policy.alb_ingress.arn]
  context               = var.context

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
