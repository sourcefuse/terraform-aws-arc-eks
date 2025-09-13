data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    values = [
      "test-subnet-private*"
    ]
  }
}
data "aws_eks_cluster" "this" {
  name = module.eks_cluster.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.eks_cluster_id
}
