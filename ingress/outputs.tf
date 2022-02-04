output "nlb_dns_name" {
  value       = data.aws_lb.eks_nlb.dns_name
  description = "DNS name of the NLB created for ingress."
}

output "nlb_zone_id" {
  value       = data.aws_lb.eks_nlb.zone_id
  description = "Route53 zone ID of the NLB created for ingress."
}
