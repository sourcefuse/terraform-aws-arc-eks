output "name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}
