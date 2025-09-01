# PostgreSQL ConfigMap for initialization script
resource "kubernetes_config_map" "postgresql_init" {
  metadata {
    name      = "init-data"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n-postgres"
    }
  }

  data = {
    "init-data.sh" = <<-EOT
      #!/bin/bash
      set -e;
      if [ -n "$${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "$${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
          psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
              CREATE USER "$${POSTGRES_NON_ROOT_USER}" WITH PASSWORD '$${POSTGRES_NON_ROOT_PASSWORD}';
              GRANT ALL PRIVILEGES ON DATABASE $${POSTGRES_DB} TO "$${POSTGRES_NON_ROOT_USER}";
          EOSQL
      else
          echo "SETUP INFO: No Environment variables given!"
      fi
    EOT
  }
}

# PostgreSQL PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "postgresql" {
  metadata {
    name      = "${var.name}-postgresql-pvc"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n-postgres"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.postgresql_storage_size
      }
    }

    storage_class_name = var.storage_class_name
  }
}

# PostgreSQL Deployment
resource "kubernetes_deployment" "postgresql" {
  metadata {
    name      = "${var.name}-postgresql"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n-postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "n8n-postgres"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "1"
      }
    }

    template {
      metadata {
        labels = {
          app = "n8n-postgres"
        }
      }

      spec {
        restart_policy = "Always"

        security_context {
          run_as_non_root = true
          run_as_user     = 999 # PostgreSQL user ID
          run_as_group    = 999 # PostgreSQL group ID
          fs_group        = 999
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        container {
          name  = "postgres"
          image = "postgres:${var.postgresql_version}"

          security_context {
            run_as_non_root            = true
            run_as_user                = 999
            run_as_group               = 999
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
            container_port = 5432
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          env {
            name = "POSTGRES_DB"
            value = "n8n" 
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name = "POSTGRES_NON_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_NON_ROOT_USER"
              }
            }
          }

          env {
            name = "POSTGRES_NON_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql.metadata[0].name
                key  = "POSTGRES_NON_ROOT_PASSWORD"
              }
            }
          }

          env {
            name  = "POSTGRES_PORT"
            value = "5432"
          }

          volume_mount {
            name       = "postgresql-pv"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "init-data"
            mount_path = "/docker-entrypoint-initdb.d/init-n8n-user.sh"
            sub_path   = "init-data.sh"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "run"
            mount_path = "/var/run/postgresql"
          }

          resources {
            requests = {
              cpu    = var.postgresql_cpu_request
              memory = var.postgresql_memory_request
            }
            limits = {
              cpu    = var.postgresql_cpu_limit
              memory = var.postgresql_memory_limit
            }
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }

        volume {
          name = "postgresql-pv"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgresql.metadata[0].name
          }
        }

        volume {
          name = "init-data"
          config_map {
            name         = kubernetes_config_map.postgresql_init.metadata[0].name
            default_mode = "0744"
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }

        volume {
          name = "run"
          empty_dir {}
        }
      }
    }
  }
}

# PostgreSQL Service
resource "kubernetes_service" "postgresql" {
  metadata {
    name      = "${var.name}-postgresql-service"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n-postgres"
    }
  }

  spec {
    selector = {
      app = "n8n-postgres"
    }

    port {
      name        = "postgres"
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
