resource "kubernetes_namespace" "n8n" {
  metadata {
    name = var.namespace_name
    labels = {
      name = var.namespace_name
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

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

    template {
      metadata {
        labels = {
          app = "n8n"
        }
      }

      spec {
        container {
          name  = "n8n"
          image = "n8nio/n8n:${var.n8n_version}"

          port {
            container_port = 5678
            name          = "http"
          }

          env {
            name = "N8N_HOST"
            value = var.n8n_host
          }

          env {
            name = "N8N_PORT"
            value = "5678"
          }

          env {
            name = "N8N_PROTOCOL"
            value = "https"
          }

          env {
            name = "NODE_ENV"
            value = "production"
          }

          env {
            name = "WEBHOOK_URL"
            value = "https://${var.n8n_host}/"
          }

          env {
            name = "GENERIC_TIMEZONE"
            value = var.timezone
          }

          env {
            name = "DB_TYPE"
            value = "postgresdb"
          }

          env {
            name = "DB_POSTGRESDB_HOST"
            value = var.postgresql_host
          }

          env {
            name = "DB_POSTGRESDB_PORT"
            value = "5432"
          }

          env {
            name = "DB_POSTGRESDB_DATABASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }

          env {
            name = "DB_POSTGRESDB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_NON_ROOT_USER"
              }
            }
          }

          env {
            name = "DB_POSTGRESDB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_NON_ROOT_PASSWORD"
              }
            }
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
            name       = "n8n-data"
            mount_path = "/home/node/.n8n"
          }

          resources {
            requests = {
              memory = var.n8n_memory_request
              cpu    = var.n8n_cpu_request
            }
            limits = {
              memory = var.n8n_memory_limit
              cpu    = var.n8n_cpu_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 5678
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 5678
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }

        volume {
          name = "n8n-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.n8n.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "n8n" {
  metadata {
    name      = "n8n"
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
    name      = "n8n-data"
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