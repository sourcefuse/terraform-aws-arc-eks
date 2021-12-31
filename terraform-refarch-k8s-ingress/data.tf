data "aws_lb" "default" {
  name = local.default_alb_shortname
}
