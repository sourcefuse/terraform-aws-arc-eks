
locals {
  kms_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid    = "AllowEKSServiceToUseKMS"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
      }
    ]
  })
}

module "kms" {
  source  = "sourcefuse/arc-kms/aws"
  version = "1.0.9"

  count = var.envelope_encryption.enable && var.envelope_encryption.key_arn == null ? 1 : 0

  deletion_window_in_days = var.envelope_encryption.kms_deletion_window_in_days
  enable_key_rotation     = true
  alias                   = "alias/${var.namespace}/${var.environment}/eks/envelope"
  policy                  = local.kms_policy
  tags                    = var.tags
}

resource "aws_iam_policy" "kms" {
  count       = var.envelope_encryption.enable && var.envelope_encryption.key_arn == null ? 1 : 0
  name        = "${var.name}-envelope-encryption"
  description = "IAM policy for EKS to use KMS for envelope encryption"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*"
        ],
        Resource = module.kms[0].key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms" {
  count      = var.envelope_encryption.enable ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.kms[0].arn
}
