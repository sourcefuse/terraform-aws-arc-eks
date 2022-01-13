
# TODO: create vars and pull from data
resource "aws_route53_record" "health_check" {
  zone_id = data.aws_route53_zone.ref_arch_domain.zone_id
  name    = "healthcheck.sfrefarch.com"
  type    = "A"

  alias {
    name                   = "ab3abd0f6c60f4fe895e2888dd277340-cb52264e230e45f1.elb.us-east-1.amazonaws.com"
    zone_id                = "Z26RNL4JYFTOTI"
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
    name                   = "ab3abd0f6c60f4fe895e2888dd277340-cb52264e230e45f1.elb.us-east-1.amazonaws.com"
    zone_id                = "Z26RNL4JYFTOTI"
    evaluate_target_health = false
  }
}
