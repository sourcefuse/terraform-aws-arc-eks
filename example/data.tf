# TODO: refactor so this doesn't get copy/pasted
###############################################
## imports
################################################
## network
data "aws_vpc" "vpc" {

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

## network
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name = "tag:Name"

    values = ["*private*"]
  }
}

data "aws_caller_identity" "source" {}

# eks cluster
data "aws_eks_cluster" "eks" {
  name = module.eks_cluster.eks_cluster_id

}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks_cluster.eks_cluster_id

}


## security
data "aws_security_groups" "db_sg" {
  filter {
    name   = "group-name"
    values = ["${var.namespace}-${var.environment}-db-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_security_groups" "eks_sg" {
  filter {
    name   = "group-name"
    values = ["${var.namespace}-${var.environment}-eks-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}
