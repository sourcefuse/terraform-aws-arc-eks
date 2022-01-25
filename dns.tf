locals {
  app_domains = [
    "healthcheck.sfrefarch.com",
    "boilerplate-ui.sfrefarch.com",
    "camunda.sfrefarch.com",
    "pgadmin.sfrefarch.com",
    "auth.sfrefarch.com",
    "audit.sfrefarch.com",
    "in-mail.sfrefarch.com",
    "workflow.sfrefarch.com",
    "video-conferencing.sfrefarch.com",
    "scheduler.sfrefarch.com",
    "notification.sfrefarch.com",
  ]
}

resource "aws_route53_record" "app_domain_records" {
  zone_id  = data.aws_route53_zone.ref_arch_domain.zone_id
  for_each = toset(local.app_domains)

  name = each.value
  type = "A"

  alias {
    name                   = data.aws_lb.eks_nlb.dns_name
    zone_id                = data.aws_lb.eks_nlb.zone_id
    evaluate_target_health = false
  }

  lifecycle {
    create_before_destroy = false
  }
}
