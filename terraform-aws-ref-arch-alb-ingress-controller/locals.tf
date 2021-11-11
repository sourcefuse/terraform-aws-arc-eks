locals {
  # TODO: inject annotations?
  # TODO: clean up
  # TODO: S3 access logs
  #  annotations = merge(var.tags, var.annotations)
  annotations = local.tags

  load_balancer_attributes = {
    # Information about a load balancer attribute.

    # The following attribute is supported by all load balancers:
    #    delete_protection_enabled = "deletion_protection.enabled=${var.deletion_protection}"
    delete_protection_enabled = "deletion_protection.enabled=false"

    #    access_logs_s3_enabled = "access_logs.s3.enabled=false"
    #    access_logs_s3_bucket = "access_logs.s3.bucket=${var.logs_s3_bucket_name}"
    #    access_logs_s3_prefix = "access_logs.s3.prefix=${var.logs_s3_prefix}"

    alb_idle_timeout               = "idle_timeout.timeout_seconds=60"
    alb_desync_mitigation_mode     = "routing.http.desync_mitigation_mode=defensive"
    alb_drop_invalid_header_fields = "routing.http.drop_invalid_header_fields.enabled=true"
    alb_http_enabled               = "routing.http2.enabled=true"
    alb_waf_fail_open_enabled      = "waf.fail_open.enabled=false"
  }

  ssl_redirect = jsonencode({
    Type : "redirect",
    RedirectConfig : {
      Protocol : "HTTPS",
      Port : 443,
      StatusCode : "HTTP_301"
    }
  })

  ingress_settings = {
    "awsVpcID" : data.aws_vpc.vpc.id
    "awsRegion" : var.region
  }

  tags = merge(var.tags, tomap({
    Module        = "terraform-aws-ref-arch-alb-ingress-controller"
    ModuleVersion = trimspace(file("${path.module}/.version"))
  }))
}
