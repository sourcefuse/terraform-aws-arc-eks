#######################################################
## defaults
#######################################################
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "profile" {
  description = "Name of the AWS profile to use"
  default     = "default"
}

variable "region" {
  description = "AWS region"
}

#######################################################
## eks / kubernetes / helm
#######################################################
variable "kubernetes_version" {
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
  default     = "1.21"
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "cluster_log_retention_period" {
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
  type        = number
  default     = 0
}

variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

## iam
variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "oidc_provider_enabled" {
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using `kiam` or `kube2iam`. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
  type        = bool
  default     = true
}

## workers
variable "local_exec_interpreter" {
  description = "shell to use for local_exec"
  type        = list(string)
  default     = ["/bin/sh", "-c"]
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided"
  type        = number
}

variable "instance_types" {
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
  type        = list(string)
}

variable "kubernetes_labels" {
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  type        = map(string)
  default     = {}
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "The maximum size of the AutoScaling Group"
  type        = number
}

variable "min_size" {
  description = "The minimum size of the AutoScaling Group"
  type        = number
}

## cluster configuration
variable "cluster_encryption_config_enabled" {
  description = "Set to `true` to enable Cluster Encryption Configuration"
  type        = bool
  default     = true
}

variable "cluster_encryption_config_kms_key_id" {
  description = "KMS Key ID to use for cluster encryption config"
  type        = string
  default     = ""
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
  type        = bool
  default     = true
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
  type        = number
  default     = 10
}

variable "cluster_encryption_config_kms_key_policy" {
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
  type        = string
  default     = null
}

variable "cluster_encryption_config_resources" {
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
  type        = list(any)
  default     = ["secrets"]
}

variable "addons" {
  description = "Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources."

  type = list(object({
    addon_name               = string
    addon_version            = string
    resolve_conflicts        = string
    service_account_role_arn = string
  }))

  default = []
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for selection"
}

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

#######################################################
## data lookups
#######################################################
variable "vpc_name" {
  description = "Name tag of the VPC used for data lookups"
}

variable "private_subnet_names" {
  description = "Name tag of the private subnets used for data lookups"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Name tag of the public subnets used for data lookups"
  type        = list(string)
}

variable "route_53_zone" {
  type        = string
  description = "Route 53 domain to generate an ACM request for and to create A records against, i.e. sfrefarch.com. A wildcard subject alternative name is generated with the certificate."
}
