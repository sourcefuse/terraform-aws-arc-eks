locals {
#  annotations = {
#    #List of available annotations on https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
#    "kubernetes.io/ingress.class"                        = "alb"
#    "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
#    "alb.ingress.kubernetes.io/target-type"              = "ip"
#    "alb.ingress.kubernetes.io/load-balancer-attributes" = join(",", values(local.load_balancer_attributes))
#    "alb.ingress.kubernetes.io/actions.ssl-redirect"     = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
#    "alb.ingress.kubernetes.io/group.name"               = "ingress-group"
#    "alb.ingress.kubernetes.io/group.order"              = "1"
#    "alb.ingress.kubernetes.io/subnets"                  = join(",", var.subnets)
#    "alb.ingress.kubernetes.io/ssl-policy"               = "ELBSecurityPolicy-TLS-1-2-2017-01"
#    "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\": 80}]"
#  }
#
#  load_balancer_attributes = {}
}
