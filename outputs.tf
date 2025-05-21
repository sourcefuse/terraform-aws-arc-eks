output "name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_id" {
  description = "The unique identifier of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "eks_cluster_security_group_id" {
  description = "The ID of the security group associated with the EKS cluster's control plane"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "oidc_provider_url" {
  description = "The OIDC identity provider URL for the EKS cluster (without the https:// prefix)"
  value       = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

output "certificate_authority_data" {
  description = "The base64-encoded certificate data required to communicate with the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}
