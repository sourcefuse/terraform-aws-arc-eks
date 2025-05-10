output "name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}
output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = aws_eks_cluster.this.id
}
output "eks_cluster_security_group_id" {
  description = "The security group attached to eks cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL without https://"
  value       = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}
output "certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_cluster_security_group" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "karpenter_instance_profile_name" {
  description = "The name of the Karpenter instance profile"
  value       = var.karpenter_config.enable ? aws_iam_instance_profile.karpenter_instance_profile[0].name : null
}

output "karpenter_controller_role_arn" {
  description = "The ARN of the Karpenter controller IAM role"
  value       = var.karpenter_config.enable ? aws_iam_role.karpenter_controller_role[0].arn : null
}
