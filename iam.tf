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
