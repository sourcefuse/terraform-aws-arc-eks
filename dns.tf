
# TODO: create vars and pull from data
resource "aws_route53_record" "health_check" {
  zone_id = data.aws_route53_zone.ref_arch_domain.zone_id
  name    = "healthcheck.sfrefarch.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_nlb.dns_name
    zone_id                = data.aws_lb.eks_nlb.zone_id
    evaluate_target_health = false
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_route53_record" "boilerplate_ui" {
  zone_id = data.aws_route53_zone.ref_arch_domain.zone_id
  name    = "boilerplate-ui.sfrefarch.com"
  type    = "A"


  alias {
    name                   = data.aws_lb.eks_nlb.dns_name
    zone_id                = data.aws_lb.eks_nlb.zone_id
    evaluate_target_health = false
  }
}