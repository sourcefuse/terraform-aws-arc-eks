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
## default service / ingress
##########################################################################
variable "default_annotations" {
  description = "Default annotations for Kubernetes Ingress."
  type        = map(any)
  default     = {}
}

variable "default_labels" {
  description = "Map of string keys and values that can be used to organize and categorize (scope and select) the service. May match selectors of replication controllers and services."
  type        = map(string)
  default     = {}
}

variable "default_name" {
  description = "Name for the default Kubernetes Ingress."
  default     = null
}

variable "default_service_load_balancer_source_ranges" {
  description = "If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature."
  type        = list(string)
  default     = []
}

variable "default_service_ports" {
  description = "The list of ports that are exposed by this service."
  type        = list(map(any))

  default = [
    {
      port = 80
    }
  ]
}

variable "default_service_selector" {
  description = "Route service traffic to pods with label keys and values matching this selector. Only applies to types ClusterIP, NodePort, and LoadBalancer."
  type        = map(any)
  default     = {}
}

variable "default_service_type" {
  description = "Determines how the service is exposed. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. ExternalName maps to the specified external_name (not yet supported)."
  default     = "ClusterIP"
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
