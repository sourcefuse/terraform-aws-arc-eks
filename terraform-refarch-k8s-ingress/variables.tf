variable "default_ingress_metadata" {
  description = "Metadata for the default Kubernetes Ingress."
  type        = map(any)
  default = {
    name = "default-ingress"
  }
}

variable "enable_internal_alb" {
  description = "Enable the internal ALB."
  type        = bool
  default     = true
}

variable "ingress_annotations" {
  description = "Annotations for Kubernetes Ingress."
}

variable "namespace" {
  description = "The namespace the resource(s) will belong to."
}

variable "private_ingress_metadata" {
  description = "Metadata for the private Kubernetes Ingress."
  type        = map(any)
  default     = {
    name = "private-ingress"
  }
}

// TODO - add description
variable "subnets" {
  type = list(string)
}

variable "time_sleep_depends_on" {
  description = "The dependency time_sleep requires."
  type        = list(any)
  default     = []
}
