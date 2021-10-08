data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["refarch-${var.environment}-vpc"]
  }
}

## network
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"

    values = [
      "refarch-${var.environment}-privatesubnet-private-${var.region}a",
      "refarch-${var.environment}-privatesubnet-private-${var.region}b"
    ]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"

    values = [
      "refarch-${var.environment}-publicsubnet-public-${var.region}a",
      "refarch-${var.environment}-publicsubnet-public-${var.region}b"
    ]
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks_cluster.eks_cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks_cluster.eks_cluster_id
}
