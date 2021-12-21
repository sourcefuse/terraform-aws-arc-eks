output "node_policy_arns" {
  value = [
    aws_iam_policy.alb_ingress.arn
  ]
}

output "namespace" {
  value = kubernetes_namespace.alb.metadata[0].name
}
