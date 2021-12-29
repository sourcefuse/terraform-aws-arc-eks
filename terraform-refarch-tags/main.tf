variable "environment" {}
variable "project" {}
variable "role" {}

locals {
  tags = {
    Environment  = var.environment
    Project      = var.project
    LastModified = formatdate("DD MMM YYYY hh:mm:ss ZZZ", timestamp())
    Role         = var.role
  }
}

output "tags" {
  value = local.tags
}
