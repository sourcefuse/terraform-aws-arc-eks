locals {
  cluster_name             = module.eks_cluster.eks_cluster_id
  kubernetes_config_map_id = module.eks_cluster.kubernetes_config_map_id
}
