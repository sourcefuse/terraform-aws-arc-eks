# TODO: refactor so this doesn't get copy/pasted
###############################################
## imports
################################################
## network
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.namespace}-${var.environment}-vpc"]
  }
}

## network
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"

    values = [
      "${var.namespace}-${var.environment}-privatesubnet-private-${var.region}a",
      "${var.namespace}-${var.environment}-privatesubnet-private-${var.region}b"
    ]
  }
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
