# resource "kubectl_manifest" "node_class" {
#   depends_on = [module.eks_cluster]
#   yaml_body = templatefile(
#     "${path.module}/files/node-class.yaml",
#     {
#       namespace    = module.common.namespace
#       environment  = var.environment
#       cluster_name = "${module.common.prefix}-cluster"
#       map_tag_value = module.common.map_tag_value
#     }
#   )
# }
