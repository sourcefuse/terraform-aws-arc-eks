## ingress
variable "ingress_namespace_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Namespace name"
}

variable "health_check_image" {
  default     = "nginx:alpine"
  description = "Image version for Nginx"
  type        = string
}

variable "health_check_domains" {
  type        = list(string)
  description = "List of A record domains to create for the health check service"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster that the ingress controller will be deployed into. This value will also be used for the 'Name' tag of the NLB."
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the ingress controller to use for L7 load balancing."
}

variable "route_53_zone_id" {
  type        = string
  description = "Route 53 zone ID to use when making an A record for the health check."
}
