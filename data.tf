## default
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

## network
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = var.private_subnet_names
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = var.public_subnet_names
  }
}

#iam

data "aws_iam_policy_document" "eks_admin" {
  statement {
    sid = "AllowEKSActions"

    actions = [
      "eks:*",
      "ec2:*"
    ]

    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = [var.name]
    }
  }

  statement {
    sid = "AllowEC2Actions"

    actions = [
      "ec2:*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/aws:eks:cluster-name"
      values   = [var.name]
    }
  }

  statement {
    sid = "AllowAutoscalingActions"

    actions = [
      "autoscaling:*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/eks:cluster-name"
      values   = [var.name]
    }
  }

  statement {
    sid = "AllowELBActions"

    actions = [
      "elasticloadbalancing:*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = [var.name]
    }
  }

}

// TODO: turn into standard module
// TODO: tighten security
// TODO: interpolate core-apps where needed, convert to helm, or use native k8s app module

# data "kubectl_path_documents" "docs" {
#   pattern = "${path.module}/manifests/*.yaml"
# }

# data "aws_eks_cluster" "eks" {
#   name = module.eks_cluster.eks_cluster_id
#   tags = var.tags
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = module.eks_cluster.eks_cluster_id
# }
