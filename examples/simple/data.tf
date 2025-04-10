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
