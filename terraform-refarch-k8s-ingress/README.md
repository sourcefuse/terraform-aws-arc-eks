# Terraform Reference Architecture: Kubernetes Ingress

## Overview

Terraform module for deploying Kubernetes Ingress.  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_ingress.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress) | resource |
| [kubernetes_service.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_annotations"></a> [default\_annotations](#input\_default\_annotations) | Default annotations for Kubernetes Ingress. | `map(any)` | `{}` | no |
| <a name="input_default_labels"></a> [default\_labels](#input\_default\_labels) | Map of string keys and values that can be used to organize and categorize (scope and select) the service. May match selectors of replication controllers and services. | `map(string)` | `{}` | no |
| <a name="input_default_name"></a> [default\_name](#input\_default\_name) | Name for the default Kubernetes Ingress. | `any` | `null` | no |
| <a name="input_default_service_load_balancer_source_ranges"></a> [default\_service\_load\_balancer\_source\_ranges](#input\_default\_service\_load\_balancer\_source\_ranges) | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. | `list(string)` | `[]` | no |
| <a name="input_default_service_ports"></a> [default\_service\_ports](#input\_default\_service\_ports) | The list of ports that are exposed by this service. | `list(map(any))` | <pre>[<br>  {<br>    "port": 80<br>  }<br>]</pre> | no |
| <a name="input_default_service_selector"></a> [default\_service\_selector](#input\_default\_service\_selector) | Route service traffic to pods with label keys and values matching this selector. Only applies to types ClusterIP, NodePort, and LoadBalancer. | `map(any)` | `{}` | no |
| <a name="input_default_service_type"></a> [default\_service\_type](#input\_default\_service\_type) | Determines how the service is exposed. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. ExternalName maps to the specified external\_name (not yet supported). | `string` | `"ClusterIP"` | no |
| <a name="input_enable_internal_alb"></a> [enable\_internal\_alb](#input\_enable\_internal\_alb) | Enable the internal ALB. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace the resource(s) will belong to. | `any` | n/a | yes |
| <a name="input_private_ingress_annotations"></a> [private\_ingress\_annotations](#input\_private\_ingress\_annotations) | Private annotations for Kubernetes Ingress. | `map(any)` | `{}` | no |
| <a name="input_private_ingress_name"></a> [private\_ingress\_name](#input\_private\_ingress\_name) | Name for the private Kubernetes Ingress. | `string` | `"private-ingress"` | no |

## Outputs

No outputs.
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
