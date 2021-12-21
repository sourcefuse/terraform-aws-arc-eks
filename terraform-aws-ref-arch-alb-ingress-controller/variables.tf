#######################################################
## defaults
#######################################################
variable "name" {
  description = "Name of this resource."
  default     = "refarch"
}

variable "region" {
  description = "Region to place the created resources in."
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC the resource will be created in"
}

variable "context" {}

#######################################################
## iam
#######################################################
variable "eks_cluster_identity_oidc_issuer" {
  description = "OIDC Issuer."
}

variable "eks_cluster_identity_oidc_issuer_arns" {
  description = "OIDC Issuer ARNs."
  type        = list(string)
}

#######################################################
## eks / helm / kube
#######################################################
variable "alb_ingress_helm_chart_name" {
  description = "URL of the Helm chart for the ingress controller"
  default     = "aws-load-balancer-controller"
}

variable "alb_ingress_helm_chart_version" {
  description = "URL of the Helm chart for the ingress controller"
  default     = "1.2.7"
}

variable "alb_ingress_helm_release_name" {
  description = "URL of the Helm chart for the ingress controller"
  default     = "aws-load-balancer-controller"
}

variable "alb_ingress_helm_repo_url" {
  default     = "https://aws.github.io/eks-charts"
  type        = string
  description = "URL of the Helm chart for the ingress controller"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster the ingress controller will connect to."
}

variable "eks_namespace" {
  description = "EKS ALB ingress controller namespace."
  default     = "alb-ingress-controller"
}

## networking / security
variable "eks_node_group_associated_security_group_ids" {
  description = "Associate additional security group ID's to the cluster"
  type        = list(string)
  default     = []
}

variable "eks_node_group_private_subnet_ids" {
  description = "List of private subnets to attach to the EKS node group"
  type        = list(string)
}

variable "eks_ingress_public_subnet_ids" {
  description = "List of public subnets for EKS ingress from the ALB."
  type        = list(string)
}

## eks nodes
variable "eks_node_group_cluster_autoscaler_enabled" {
  description = "Set true to label the node group so that the Kubernetes Cluster Autoscaler will discover and autoscale it."
  type        = bool
  default     = true
}

variable "eks_node_group_create_before_destroy" {
  description = "Set true in order to create the new node group before destroying the old one. If false, the old node group will be destroyed first, causing downtime. Changing this setting will always cause node group to be replaced."
  type        = bool
  default     = true
}

variable "eks_node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "eks_node_group_instance_types" {
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
  type        = list(string)
}

variable "eks_node_group_kubernetes_labels" {
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  type        = map(string)
  default     = {}
}

variable "eks_node_group_max_size" {
  description = "The maximum size of the AutoScaling Group"
  type        = number
}

variable "eks_node_group_min_size" {
  description = "The minimum size of the AutoScaling Group"
  type        = number
}

variable "kubernetes_config_map_id" {
  description = "Config map ID of the Kubernetes cluster."
}

#######################################################
## tags
#######################################################
variable "tags" {
  description = "Tags to assign the resources."
  type        = map(any)
  default     = {}
}
