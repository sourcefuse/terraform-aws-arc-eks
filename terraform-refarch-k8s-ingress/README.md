# Terraform Reference Architecture: Kubernetes Ingress

## Overview

Terraform module for deploying Kubernetes Ingress.  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default_alb_alias"></a> [default\_alb\_alias](#module\_default\_alb\_alias) | git::https://github.com/cloudposse/terraform-aws-route53-alias | 0.12.1 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_ingress.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress) | resource |
| [kubernetes_service.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_lb.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_alb_additional_aliases"></a> [default\_alb\_additional\_aliases](#input\_default\_alb\_additional\_aliases) | List of additional aliases for the default ALB. | `list(string)` | `[]` | no |
| <a name="input_default_ingress_alias"></a> [default\_ingress\_alias](#input\_default\_ingress\_alias) | FQDN to assign as an alias to the ALB. | `string` | `""` | no |
| <a name="input_default_ingress_annotations"></a> [default\_ingress\_annotations](#input\_default\_ingress\_annotations) | Default annotations for Kubernetes Ingress. | `map(any)` | `{}` | no |
| <a name="input_default_ingress_name"></a> [default\_ingress\_name](#input\_default\_ingress\_name) | Name for the default Kubernetes Ingress. | `any` | `null` | no |
| <a name="input_default_ingress_prevent_destroy"></a> [default\_ingress\_prevent\_destroy](#input\_default\_ingress\_prevent\_destroy) | Prevent destruction of the default ALB. | `bool` | `false` | no |
| <a name="input_default_ingress_rules"></a> [default\_ingress\_rules](#input\_default\_ingress\_rules) | Rules for the default Kubernetes Ingress. | `list(map(any))` | `[]` | no |
| <a name="input_default_labels"></a> [default\_labels](#input\_default\_labels) | Map of string keys and values that can be used to organize and categorize (scope and select) the service. May match selectors of replication controllers and services. | `map(string)` | `{}` | no |
| <a name="input_default_parent_route53_zone_id"></a> [default\_parent\_route53\_zone\_id](#input\_default\_parent\_route53\_zone\_id) | The ID to the parent Route 53 zone. | `any` | `null` | no |
| <a name="input_default_service_annotations"></a> [default\_service\_annotations](#input\_default\_service\_annotations) | Default annotations for Kubernetes service. | `map(any)` | `{}` | no |
| <a name="input_default_service_load_balancer_source_ranges"></a> [default\_service\_load\_balancer\_source\_ranges](#input\_default\_service\_load\_balancer\_source\_ranges) | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. | `list(string)` | `[]` | no |
| <a name="input_default_service_name"></a> [default\_service\_name](#input\_default\_service\_name) | Name for the default Kubernetes Service. | `any` | `null` | no |
| <a name="input_default_service_ports"></a> [default\_service\_ports](#input\_default\_service\_ports) | The list of ports that are exposed by this service. | `list(map(any))` | <pre>[<br>  {<br>    "port": 80<br>  }<br>]</pre> | no |
| <a name="input_default_service_selector"></a> [default\_service\_selector](#input\_default\_service\_selector) | Route service traffic to pods with label keys and values matching this selector. Only applies to types ClusterIP, NodePort, and LoadBalancer. | `map(any)` | `{}` | no |
| <a name="input_default_service_type"></a> [default\_service\_type](#input\_default\_service\_type) | Determines how the service is exposed. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. ExternalName maps to the specified external\_name (not yet supported). | `string` | `"ClusterIP"` | no |
| <a name="input_enable_internal_alb"></a> [enable\_internal\_alb](#input\_enable\_internal\_alb) | Enable the internal ALB. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace the resource(s) will belong to. | `any` | n/a | yes |
| <a name="input_private_ingress_annotations"></a> [private\_ingress\_annotations](#input\_private\_ingress\_annotations) | Private annotations for Kubernetes Ingress. | `map(any)` | `{}` | no |
| <a name="input_private_ingress_name"></a> [private\_ingress\_name](#input\_private\_ingress\_name) | Name for the private Kubernetes Ingress. | `string` | `"private-ingress"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_default_alb_hostname"></a> [default\_alb\_hostname](#output\_default\_alb\_hostname) | n/a |
| <a name="output_default_alb_shortname"></a> [default\_alb\_shortname](#output\_default\_alb\_shortname) | n/a |
| <a name="output_default_service_name"></a> [default\_service\_name](#output\_default\_service\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Development

### Prerequisites

* [golang](https://golang.org/doc/install#install)
* [golint](https://github.com/golang/lint#installation)
* [pre-commit](https://pre-commit.com/#install)
* [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
* [terraform-docs](https://github.com/segmentio/terraform-docs)

### Configurations
* Configure pre-commit hooks  
```sh
pre-commit install
```

* Configure golang deps for tests
```sh
go get github.com/gruntwork-io/terratest/modules/terraform
go get github.com/stretchr/testify/assert
```

## Authors

This project is authored by:  
* SourceFuse  
