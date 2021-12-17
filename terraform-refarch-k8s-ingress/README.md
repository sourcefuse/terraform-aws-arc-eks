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
| [kubernetes_ingress.default_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress) | resource |
| [kubernetes_ingress.private_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_ingress_annotations"></a> [default\_ingress\_annotations](#input\_default\_ingress\_annotations) | Default annotations for Kubernetes Ingress. | `map(any)` | `{}` | no |
| <a name="input_default_ingress_name"></a> [default\_ingress\_name](#input\_default\_ingress\_name) | Name for the default Kubernetes Ingress. | `string` | `"default-ingress"` | no |
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
