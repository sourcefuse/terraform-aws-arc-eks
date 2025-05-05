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
