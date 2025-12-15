resource "kubernetes_ingress_v1" "ingress_development" {
  metadata {
    name      = lower(join("-", [local.org_short_name, "ingress", "development"]))
    namespace = "development"

    annotations = {
      "kubernetes.io/ingress.class"          = "alb"
      "alb.ingress.kubernetes.io/group.name" = lower(join("-", [local.org_short_name, "ingress", "development"]))
      "alb.ingress.kubernetes.io/actions.redirect" = jsonencode({
        Type = "redirect",
        RedirectConfig = {
          Protocol   = "HTTPS"
          Port       = "443"
          StatusCode = "HTTP_301"
        }
      })
      "alb.ingress.kubernetes.io/backend-protocol"             = "HTTP"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/subnets"                      = join(",", module.vpc.public_subnets)
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "8"
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = "3"
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "2"
      "alb.ingress.kubernetes.io/target-group-attributes"      = "slow_start.duration_seconds=30,deregistration_delay.timeout_seconds=60"
      "alb.ingress.kubernetes.io/actions.response-200" = jsonencode({
        type = "fixed-response",
        fixedResponseConfig = {
          Protocol    = "HTTPS"
          Port        = "443"
          ContentType = "text/html"
          StatusCode  = "401"
          MessageBody = "<!DOCTYPE html><html> <head> <title>Unauthorized Access</title> </head> <body> <h1>Oops!</h1> <p> Hold it right there, buddy! You're not authorized to access this page. Did you forget to bring your permission slip?</p> </body></html>"
        }
      })
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service_v1.service_particle41_app_development.metadata.0.name

              port {
                number = kubernetes_service_v1.service_particle41_app_development.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}
