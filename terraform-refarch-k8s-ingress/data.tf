data "aws_lb" "default" {
  count = var.default_parent_route53_zone_id != null ? 1 : 0
  name  = local.default_alb_shortname
}
