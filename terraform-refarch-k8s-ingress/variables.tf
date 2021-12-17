##########################################################################
## shared
##########################################################################
variable "namespace" {
  description = "The namespace the resource(s) will belong to."
}

// TODO - remove if not needed
#variable "subnets" {
#  description = "List of subnets to associate with ingress."
#  type        = list(string)
#}

##########################################################################
## default ingress
##########################################################################
variable "default_ingress_annotations" {
  description = "Default annotations for Kubernetes Ingress."
  type        = map(any)
  default     = {}
}

variable "default_ingress_name" {
  description = "Name for the default Kubernetes Ingress."
  default     = "default-ingress"
}

##########################################################################
## private ingress
##########################################################################
variable "enable_internal_alb" {
  description = "Enable the internal ALB."
  type        = bool
  default     = true
}

variable "private_ingress_annotations" {
  description = "Private annotations for Kubernetes Ingress."
  type        = map(any)
  default     = {}
}

variable "private_ingress_name" {
  description = "Name for the private Kubernetes Ingress."
  default     = "private-ingress"
}
