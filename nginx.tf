
# TODO: create vars and pull from data
resource "aws_route53_record" "default_alb_alias" {
  zone_id = data.aws_route53_zone.ref_arch_domain.zone_id
  name    = "healthcheck.sfrefarch.com"
  type    = "A"

  alias {
    name                   = "a3da605eaff254e5185645d350ae79b7-c01680831696b142.elb.us-east-1.amazonaws.com"
    zone_id                = "Z26RNL4JYFTOTI"
    evaluate_target_health = false
  }
}
