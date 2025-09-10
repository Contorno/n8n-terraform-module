resource "kubernetes_deployment" "n8n" {
  metadata {
    name      = "n8n"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n"
    }
  }

  spec {
    replicas = var.n8n_replicas

    selector {
      match_labels = {
        app = "n8n"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "n8n"
        }
      }

      spec {
        restart_policy = "Always"

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name    = "n8n"
          image   = "n8nio/n8n:${var.n8n_version}"
          command = ["/bin/sh"]
          args    = ["-c", "sleep 5; n8n start"]

          security_context {
            run_as_non_root            = true
            run_as_user                = 1000
            run_as_group               = 1000
            allow_privilege_escalation = false
            read_only_root_filesystem  = false
            capabilities {
              drop = ["ALL"]
            }
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }

          port {
            container_port = 5678
          }

          env {
            name  = "WEBHOOK_URL"
            value = "http://${var.n8n_webhook_host}/"
          }
          env {
            name  = "N8N_HOST"
            value = var.n8n_host
          }
          env {
            name  = "GENERIC_TIMEZONE"
            value = var.timezone
          }
          env {
            name  = "DB_TYPE"
            value = "sqlite"
          }
          env {
            name  = "N8N_PROTOCOL"
            value = "http"
          }
          env {
            name  = "N8N_PORT"
            value = "5678"
          }
          env {
            name  = "DB_SQLITE_POOL_SIZE"
            value = "2"
          }
          env {
            name  = "N8N_HIRING_BANNER_ENABLED"
            value = "false"
          }
          env {
            name  = "N8N_REINSTALL_MISSING_PACKAGES"
            value = "true"
          }
          env {
            name  = "N8N_METRICS"
            value = "true"
          }
          env {
            name = "N8N_ENCRYPTION_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.n8n.metadata[0].name
                key  = "N8N_ENCRYPTION_KEY"
              }
            }
          }

          volume_mount {
            name       = "n8n-claim0"
            mount_path = "/home/node/.n8n"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          resources {
            requests = {
              memory = var.n8n_memory_request
            }
            limits = {
              memory = var.n8n_memory_limit
            }
          }
        }

        volume {
          name = "n8n-claim0"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.n8n.metadata[0].name
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }

        volume {
          name = "n8n-secret"
          secret {
            secret_name = kubernetes_secret.n8n.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "n8n" {
  metadata {
    name      = "${var.name}-service"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n"
    }
  }

  spec {
    selector = {
      app = "n8n"
    }

    port {
      port        = 5678
      target_port = 5678
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}



resource "kubernetes_persistent_volume_claim" "n8n" {
  metadata {
    name      = "${var.name}-pv-claim0"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.n8n_storage_size
      }
    }

    storage_class_name = var.storage_class_name
  }
}
