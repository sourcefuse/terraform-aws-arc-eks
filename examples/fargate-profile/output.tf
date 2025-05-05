output "eks_name" {
  value = module.eks_cluster.name
}
output "eks_cluster_security_group_id" {
  description = "The security group attached to eks cluster"
  value       = module.eks_cluster.eks_cluster_security_group_id
}
