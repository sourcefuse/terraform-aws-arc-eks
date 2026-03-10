locals {
  vpc_config = {
    subnet_ids = data.aws_subnets.private.ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config = {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  envelope_encryption = {
    enable    = true
    resources = ["secrets"]
  }

  kubernetes_network_config = {
    ip_family = "ipv4"
  }

  # EKS Capabilities Configuration
  eks_capabilities_config = {
    enable = true
    capabilities = [
      # ArgoCD Capability
      {
        name            = "argocd-capability"
        capability_name = "ArgoCD"
        type            = "ARGOCD"
        role_arn        = aws_iam_role.argocd_role.arn
        argocd_config = {
          namespace = "argocd"
          # AWS IAM Identity Center is required by the provider
          # You need to provide your actual IAM Identity Center instance ARN
          aws_idc = {
            idc_instance_arn = "arn:aws:sso:::instance/ssoins-7xxxxxxxx"
            idc_region       = "us-east-1"
          }
          # Optional: Configure network access with VPC endpoints
          # network_access = {
          #   vpce_ids = ["vpce-xxxxxxxx", "vpce-yyyyyyyy"]
          # }
          # Optional: Configure RBAC role mappings
          rbac_role_mapping = [
            {
              role     = "ADMIN"
              identity = [
                {
                  id   = "142xxxx8-cxx1-7xxx-axxa-5xxxxxxx7"
                  type = "SSO_USER"
                }
              ]
            }
          ]
        }
      },
      # ACK EC2 Capability
      {
        name            = "ack-ec2-capability"
        capability_name = "ACK-EC2"
        type            = "ACK"
        role_arn        = aws_iam_role.ack_ec2_role.arn
      },
      # ACK S3 Capability
      {
        name            = "ack-s3-capability"
        capability_name = "ACK-S3"
        type            = "ACK"
        role_arn        = aws_iam_role.ack_s3_role.arn
      },
      # KRO (Kubernetes Resource Operator) Capability
      {
        name            = "kro-capability"
        capability_name = "KRO"
        type            = "KRO"
        role_arn        = aws_iam_role.kro_role.arn
      }
    ]
  }
}

# IAM Role for ArgoCD
resource "aws_iam_role" "argocd_role" {
  name = "${var.namespace}-${var.environment}-argocd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect   = "Allow"
        Principal = {
          Service = "capabilities.eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ArgoCD
resource "aws_iam_role_policy" "argocd_policy" {
  name = "${var.namespace}-${var.environment}-argocd-policy"
  role = aws_iam_role.argocd_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.argocd_role.arn
      }
    ]
  })
}

# IAM Role for ACK EC2
resource "aws_iam_role" "ack_ec2_role" {
  name = "${var.namespace}-${var.environment}-ack-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect   = "Allow"
        Principal = {
          Service = "capabilities.eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ACK EC2
resource "aws_iam_role_policy" "ack_ec2_policy" {
  name = "${var.namespace}-${var.environment}-ack-ec2-policy"
  role = aws_iam_role.ack_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for ACK S3
resource "aws_iam_role" "ack_s3_role" {
  name = "${var.namespace}-${var.environment}-ack-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect   = "Allow"
        Principal = {
          Service = "capabilities.eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ACK S3
resource "aws_iam_role_policy" "ack_s3_policy" {
  name = "${var.namespace}-${var.environment}-ack-s3-policy"
  role = aws_iam_role.ack_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for KRO
resource "aws_iam_role" "kro_role" {
  name = "${var.namespace}-${var.environment}-kro-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect   = "Allow"
        Principal = {
          Service = "capabilities.eks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for KRO
resource "aws_iam_role_policy" "kro_policy" {
  name = "${var.namespace}-${var.environment}-kro-policy"
  role = aws_iam_role.kro_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kro:*"
        ]
        Resource = "*"
      }
    ]
  })
}