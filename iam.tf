resource "aws_iam_role" "auto" {
  count = var.auto_mode_config.enable ? 1 : 0
  name  = "${var.namespace}-${var.environment}-eks-auto-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  count      = var.auto_mode_config.enable ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.auto[0].name
}

locals {
  node_polices = ["AmazonEC2ContainerRegistryPullOnly", "AmazonEKS_CNI_Policy", "AmazonEKSComputePolicy", "AmazonEKSLoadBalancingPolicy", "AmazonEKSNetworkingPolicy",
  "AmazonEKSServicePolicy", "AmazonEKSWorkerNodePolicy", "AmazonEKSVPCResourceController", "AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_role_policy_attachment" "node_polcies" {
  for_each   = var.auto_mode_config.enable ? toset(local.node_polices) : []
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.auto[0].name
}

data "aws_iam_policy_document" "iam" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"

    actions = [
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:ListInstanceProfiles",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfilesForRole",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.id}:instance-profile/*${var.name}*",
      "arn:aws:iam::${data.aws_caller_identity.current.id}:role/*"
    ]
  }
}

resource "aws_iam_policy" "iam" {
  name   = "${var.name}-eks-iam-policy"
  policy = data.aws_iam_policy_document.iam.json
}

resource "aws_iam_role_policy_attachment" "iam" {
  policy_arn = aws_iam_policy.iam.arn
  role       = aws_iam_role.this.name
}


################################################################################
# Node Group IAM
################################################################################

resource "aws_iam_role" "eks_node_group" {
  for_each = var.node_group_config.enable ? var.node_group_config.config : {}

  name = "${var.namespace}-${var.environment}-${each.key}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.node_group_config.enable ? {
    for pair in flatten([
      for k, v in var.node_group_config.config : [
        for policy in local.node_group_policy_arns : {
          key        = "${k}-${replace(policy, ":", "-")}"
          role_key   = k
          policy_arn = policy
        }
      ]
      ]) : pair.key => {
      role_key   = pair.role_key
      policy_arn = pair.policy_arn
    }
  } : {}

  role       = aws_iam_role.eks_node_group[each.value.role_key].name
  policy_arn = each.value.policy_arn
}



################################################################################
# Fargate Profile IAM
################################################################################

resource "aws_iam_role" "eks_fargate_profile" {
  count = var.fargate_profile_config.enable ? 1 : 0
  name  = "${var.namespace}-${var.environment}-fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "fargate" {
  for_each   = var.fargate_profile_config.enable ? toset(local.fargate_profile_policy_arns) : toset([])
  role       = aws_iam_role.eks_fargate_profile[0].name
  policy_arn = each.value
}


################################################################################
# Karpenter IAM
################################################################################
resource "aws_iam_role_policy_attachment" "karpenter_node_policy_attachment" {
  for_each = var.karpenter_config.enable ? {
    for policy_arn in local.all_karpenter_node_role_policies : policy_arn => policy_arn
  } : {}

  role       = aws_iam_role.karpenter_node_role[0].name
  policy_arn = each.value
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_iam_role" "karpenter_node_role" {
  count = var.karpenter_config.enable ? 1 : 0
  name  = "KarpenterNodeRole-${aws_eks_cluster.this.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  count = var.karpenter_config.enable ? 1 : 0
  name  = "KarpenterNodeInstanceProfile-${aws_eks_cluster.this.name}"
  role  = aws_iam_role.karpenter_node_role[0].name
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_iam_role" "karpenter_controller_role" {
  count = var.karpenter_config.enable ? 1 : 0
  name  = "KarpenterControllerRole-${aws_eks_cluster.this.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
        }
      }
    }]
  })
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}

resource "aws_iam_role_policy" "karpenter_controller_policy" {
  count = var.karpenter_config.enable ? 1 : 0
  role  = aws_iam_role.karpenter_controller_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Karpenter"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ]
        Resource = "*"
      },
      {
        Sid      = "ConditionalEC2Termination"
        Effect   = "Allow"
        Action   = "ec2:TerminateInstances"
        Resource = "*"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/nodeclaim" = "*"
          }
        }
      },
      {
        Sid      = "PassNodeIAMRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.karpenter_node_role[0].arn
      },
      {
        Sid      = "EKSClusterEndpointLookup"
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = aws_eks_cluster.this.arn
      },
      {
        Sid    = "InstanceProfilePermissions"
        Effect = "Allow"
        Action = [
          "iam:GetInstanceProfile"
        ]
        Resource = aws_iam_instance_profile.karpenter_instance_profile[0].arn
      }
    ]
  })
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this
  ]
}
