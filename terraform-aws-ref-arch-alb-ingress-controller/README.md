# Terraform AWS: ALB Ingress Controller

## Overview

Terraform module for deploying an ALB Ingress Controller to a Kubernetes cluster.  


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_node_group"></a> [eks\_node\_group](#module\_eks\_node\_group) | cloudposse/eks-node-group/aws | 0.26.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.alb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.alb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.alb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.alb_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.alb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [time_sleep.helm_ingress_sleep](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.alb_ingress_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_ingress_helm_chart_name"></a> [alb\_ingress\_helm\_chart\_name](#input\_alb\_ingress\_helm\_chart\_name) | URL of the Helm chart for the ingress controller | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_alb_ingress_helm_chart_version"></a> [alb\_ingress\_helm\_chart\_version](#input\_alb\_ingress\_helm\_chart\_version) | URL of the Helm chart for the ingress controller | `string` | `"1.2.7"` | no |
| <a name="input_alb_ingress_helm_release_name"></a> [alb\_ingress\_helm\_release\_name](#input\_alb\_ingress\_helm\_release\_name) | URL of the Helm chart for the ingress controller | `string` | `"aws-load-balancer-controller"` | no |
| <a name="input_alb_ingress_helm_repo_url"></a> [alb\_ingress\_helm\_repo\_url](#input\_alb\_ingress\_helm\_repo\_url) | URL of the Helm chart for the ingress controller | `string` | `"https://aws.github.io/eks-charts"` | no |
| <a name="input_context"></a> [context](#input\_context) | n/a | `any` | n/a | yes |
| <a name="input_eks_cluster_identity_oidc_issuer"></a> [eks\_cluster\_identity\_oidc\_issuer](#input\_eks\_cluster\_identity\_oidc\_issuer) | OIDC Issuer. | `any` | n/a | yes |
| <a name="input_eks_cluster_identity_oidc_issuer_arns"></a> [eks\_cluster\_identity\_oidc\_issuer\_arns](#input\_eks\_cluster\_identity\_oidc\_issuer\_arns) | OIDC Issuer ARNs. | `list(string)` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster the ingress controller will connect to. | `any` | n/a | yes |
| <a name="input_eks_ingress_public_subnet_ids"></a> [eks\_ingress\_public\_subnet\_ids](#input\_eks\_ingress\_public\_subnet\_ids) | List of public subnets for EKS ingress from the ALB. | `list(string)` | n/a | yes |
| <a name="input_eks_namespace"></a> [eks\_namespace](#input\_eks\_namespace) | EKS ALB ingress controller namespace. | `string` | `"alb-ingress-controller"` | no |
| <a name="input_eks_node_group_associated_security_group_ids"></a> [eks\_node\_group\_associated\_security\_group\_ids](#input\_eks\_node\_group\_associated\_security\_group\_ids) | Associate additional security group ID's to the cluster | `list(string)` | `[]` | no |
| <a name="input_eks_node_group_desired_size"></a> [eks\_node\_group\_desired\_size](#input\_eks\_node\_group\_desired\_size) | Desired number of worker nodes | `number` | n/a | yes |
| <a name="input_eks_node_group_instance_types"></a> [eks\_node\_group\_instance\_types](#input\_eks\_node\_group\_instance\_types) | Set of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]. Terraform will only perform drift detection if a configuration value is provided | `list(string)` | n/a | yes |
| <a name="input_eks_node_group_kubernetes_labels"></a> [eks\_node\_group\_kubernetes\_labels](#input\_eks\_node\_group\_kubernetes\_labels) | Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `{}` | no |
| <a name="input_eks_node_group_max_size"></a> [eks\_node\_group\_max\_size](#input\_eks\_node\_group\_max\_size) | The maximum size of the AutoScaling Group | `number` | n/a | yes |
| <a name="input_eks_node_group_min_size"></a> [eks\_node\_group\_min\_size](#input\_eks\_node\_group\_min\_size) | The minimum size of the AutoScaling Group | `number` | n/a | yes |
| <a name="input_eks_node_group_private_subnet_ids"></a> [eks\_node\_group\_private\_subnet\_ids](#input\_eks\_node\_group\_private\_subnet\_ids) | List of private subnets to attach to the EKS node group | `list(string)` | n/a | yes |
| <a name="input_kubernetes_config_map_id"></a> [kubernetes\_config\_map\_id](#input\_kubernetes\_config\_map\_id) | Config map ID of the Kubernetes cluster. | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of this resource. | `string` | `"refarch"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to place the created resources in. | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign the resources. | `map(any)` | `{}` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC the resource will be created in | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | n/a |
| <a name="output_node_policy_arns"></a> [node\_policy\_arns](#output\_node\_policy\_arns) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Development

### Prerequisites

* [Docker (Optional)](https://docs.docker.com/engine/install/)
* [golang](https://golang.org/doc/install#install)
* [golint](https://github.com/golang/lint#installation)
* [pre-commit](https://pre-commit.com/#install)
* [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
* [terraform-docs](https://github.com/segmentio/terraform-docs)

### Configurations

### Tests
:warning: This section is still under construction :warning:  

Tests are available in `test` directory located in the root of this project.    

#### Adding a new test  
When something new has been added to the terraform `example` configuration, it needs to be updated to include testing. 
This can be achieved by adding the test to `test/example_test.go`.  

* For more information on Terratest, please see their [_Getting Started_](https://terratest.gruntwork.io/docs/#getting-started) docs.  
* For more information on k8s testing, see the [k8s docs](https://pkg.go.dev/github.com/gruntwork-io/terratest/modules/k8s?utm_source=godoc).


#### Running with Docker
The following instructions will be done from the root of the project.  

* Build the image locally:  
  ```shell
  docker build -t terraform-k8s-app-test -f Dockerfile-test .
  ```
  
* Start the container:
  ```shell
  docker run -it -v $HOME/.kube/config:/home/tester/.kube/config:ro --net=host  terraform-k8s-app-test
  ```

#### Running on the local system
**TL;DR:** From the `test` directory, run `go-test.sh` to get all requirements and run a test.  

* Configure golang deps for tests
  ```sh
  go get github.com/gruntwork-io/terratest/modules/terraform
  go get github.com/gruntwork-io/terratest/modules/k8s
  go get github.com/stretchr/testify/assert
  go get testing
  go get fmt
  ```

  **-OR-**  
  
  ```shell
  ./go-get.sh 
  ```

* From the `test` directory, run the below command:
  ```sh
  go test
  ```
  
  **-OR-**  
  
  ```shell
  ./go-test.sh 
  ```

## Authors

This project is authored by:  
* SourceFuse  
