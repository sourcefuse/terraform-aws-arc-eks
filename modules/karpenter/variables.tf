variable "karpenter_config" {
  description = "Configuration for Karpenter"
  type = object({
    cluster_name               = string
    cluster_endpoint           = string
    cluster_oidc_provider      = string
    cluster_arn                = string
    karpenter_version          = optional(string, "0.36.0")
    helm_repository            = optional(string, "oci://public.ecr.aws/karpenter")
    certificate_authority_data = string
  })
}
