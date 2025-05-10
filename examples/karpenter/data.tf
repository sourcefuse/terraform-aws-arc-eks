# data "aws_vpc" "vpc" {
#   filter {
#     name   = "tag:Name"
#     values = ["${var.namespace}-${var.environment}-vpc"]
#   }
# }

## network
data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    values = [
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}a",
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}b"
    ]
  }
}


data "aws_eks_cluster" "this" {
  name = module.eks_cluster.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.eks_cluster_id
}

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks_cluster.name
# }
data "aws_iam_role" "karpenter_controller_role" {
  name = "KarpenterControllerRole-${data.aws_eks_cluster.this.name}"
}

data "aws_iam_instance_profile" "karpenter_instance_profile" {
  name = "KarpenterNodeInstanceProfile-${data.aws_eks_cluster.this.name}"
}
