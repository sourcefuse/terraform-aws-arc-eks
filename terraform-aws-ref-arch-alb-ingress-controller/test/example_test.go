package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformExample(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../example/.",
	}
	defer terraform.Destroy(t, terraformOptions)

	// example test values
	namespaceName := fmt.Sprintf("terratest")
	secretName := fmt.Sprintf("nginx-secret")
	serviceName := fmt.Sprintf("nginx")
	servicePort := fmt.Sprintf("80")
	k8sHost := fmt.Sprintf("nginx.terratest.svc.cluster.local")

	terraform.InitAndApply(t, terraformOptions)

	assert := assert.New(t)

	// check terraform output is valid
	kubernetesServiceNameOutputValue := terraform.Output(t, terraformOptions, "kubernetes_service_name")
	assert.NotNil(kubernetesServiceNameOutputValue)
	assert.Equal(serviceName, kubernetesServiceNameOutputValue)

	kubernetesServicePortOutputValue := terraform.Output(t, terraformOptions, "kubernetes_service_port")
	assert.NotNil(kubernetesServicePortOutputValue)
	assert.Equal(servicePort, kubernetesServicePortOutputValue)

	kubernetesHostOutputValue := terraform.Output(t, terraformOptions, "kubernetes_host")
	assert.NotNil(kubernetesHostOutputValue)
	assert.Equal(k8sHost, kubernetesHostOutputValue)

	kubernetesNamespaceOutputValue := terraform.Output(t, terraformOptions, "kubernetes_namespace")
	assert.NotNil(kubernetesNamespaceOutputValue)
	assert.Equal(namespaceName, kubernetesNamespaceOutputValue)

	// check kubernetes configuration matches what is configured
	k8sOptions := k8s.NewKubectlOptions("", "", namespaceName)

	namespace := k8s.GetNamespace(t, k8sOptions, namespaceName)
	assert.NotNil(namespace)
	assert.Equal(namespaceName, namespace.Name)

	service := k8s.GetService(t, k8sOptions, serviceName)
	assert.NotNil(service)
	assert.Equal(serviceName, service.Name)

	secret := k8s.GetSecret(t, k8sOptions, secretName)
	assert.NotNil(secret)
	assert.Equal(secretName, secret.Name)
}
