resource "kubernetes_deployment_v1" "deployment_particle41_app_development" {
  metadata {
    name      = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
    namespace = kubernetes_namespace_v1.namespace_development.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
    }
  }

  spec {
    replicas                  = var.replicas
    min_ready_seconds         = 15
    progress_deadline_seconds = 600

    selector {
      match_labels = {
        app = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "25%"
        max_unavailable = 0
      }
    }

    template {
      metadata {
        annotations = {
          "configmap.reloader.stakater.com/reload" = kubernetes_config_map_v1.config_map_particle41_app_development.metadata[0].name
        }

        labels = {
          app                      = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
          "app.kubernetes.io/name" = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.service_account_development.metadata[0].name

        termination_grace_period_seconds = 60

        container {
          name              = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
          image             = var.app_image
          image_pull_policy = "Always"

          resources {
            limits = {
              cpu                 = "500m"
              memory              = "512Mi"
              "ephemeral-storage" = "1Gi"
            }

            requests = {
              cpu                 = "200m"
              memory              = "384Mi"
              "ephemeral-storage" = "1Gi"
            }
          }

          startup_probe {
            http_get {
              path = "/"
              port = var.container_port
            }

            failure_threshold = 30
            period_seconds    = 10
            timeout_seconds   = 3
          }

          liveness_probe {
            initial_delay_seconds = 0
            timeout_seconds       = 30
            period_seconds        = 10

            http_get {
              path = "/"
              port = var.container_port
            }
          }

          readiness_probe {
            failure_threshold     = 3
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 3

            http_get {
              path   = "/"
              port   = var.container_port
              scheme = "HTTP"
            }
          }

          port {
            name           = "http"
            container_port = var.container_port
            protocol       = "TCP"
          }

          dynamic "env" {
            for_each = kubernetes_config_map_v1.config_map_particle41_app_development.data

            content {
              name = env.key

              value_from {
                config_map_key_ref {
                  name = kubernetes_config_map_v1.config_map_particle41_app_development.metadata[0].name
                  key  = env.key
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "service_particle41_app_development" {
  metadata {
    name      = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
    namespace = kubernetes_namespace_v1.namespace_development.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.deployment_particle41_app_development.metadata[0].name
    }

    type = "NodePort"

    port {
      port        = var.container_port
      target_port = var.container_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_config_map_v1" "config_map_particle41_app_development" {
  metadata {
    name      = lower(join("-", [local.org_short_name, "particle41", "app", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
    namespace = kubernetes_namespace_v1.namespace_development.metadata[0].name
  }

  data = {
    NODE_ENV  = "production"
    NAMESPACE = kubernetes_namespace_v1.namespace_development.metadata[0].name

    PORT = var.container_port
  }
}
