data "aws_caller_identity" "source" {}

#iam

data "aws_iam_policy_document" "eks_admin_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = local.admin_principal
    }
  }
}

data "aws_iam_policy_document" "eks_admin" {
  statement {
    sid = "AllowEKSReadActions"

    actions = [
      "eks:ListNodegroups",
      "eks:ListTagsForResource",
      "eks:CreateNodegroup",
      "eks:CreateFargateProfile",
      "eks:ListClusters"
    ]

    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowEKSUpdateActions"

    actions = [
      "eks:TagResource",
      "eks:AccessKubernetesApi",
      "eks:DeleteNodegroup",
      "eks:UpdateNodegroupVersion",
      "eks:UpdateNodegroupConfig",
      "eks:DescribeNodegroup",
      "eks:ListFargateProfiles",
      "eks:DescribeFargateProfile",
      "eks:ListUpdates",
      "eks:DescribeUpdate",
      "eks:DescribeCluster",
      "eks:UpdateClusterConfig",
      "eks:UntagResource",
      "eks:DescribeIdentityProviderConfig",
    ]

    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = [module.eks_cluster.eks_cluster_id]
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
      values   = [module.eks_cluster.eks_cluster_id]
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
      values   = [module.eks_cluster.eks_cluster_id]
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
      values   = [module.eks_cluster.eks_cluster_id]
    }
  }

}

// TODO: turn into standard module
// TODO: tighten security
// TODO: interpolate core-apps where needed, convert to helm, or use native k8s app module
