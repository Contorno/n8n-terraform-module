resource "helm_release" "n8n" {
  name       = "n8n"
  repository = "https://community-charts.github.io/helm-charts"
  chart      = "n8n"
  version    = "1.15.4"

  namespace        = kubernetes_namespace.n8n.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      image = {
        repository = "n8nio/n8n"
        tag        = "1.109.2"
        pullPolicy = "IfNotPresent"
      }
      log = {
        level  = "info"
        output = ["console"]
      }
      main = {
        persistence = {
          enabled      = true
          accessMode   = "ReadWriteOnce" # Changed from access_mode
          storageClass = var.storage_class_name
          size         = var.n8n_storage_size
        }
        resources = {
          requests = {
            memory = "512Mi"
            cpu    = "500m"
          }
          limits = {
            memory = "2Gi"
            cpu    = "2000m"
          }
        }
      }
      db = {
        type = "postgresdb"
      }
      postgresql = {
        enabled = true
        primary = {
          persistence = {
            enabled = true
            size    = "20Gi"
          }
        }
      }
      worker = {
        mode = "regular"
      }
      redis = {
        enabled      = true
        architecture = "standalone"
        master = {
          persistence = {
            enabled = true
            size    = "5Gi"
          }
        }
      }
      webhook = {
        mode = "regular"
        url  = "https://${var.n8n_host}/" # Use variable instead of hardcoded
      }
      workflowHistory = {
        enabled   = true
        pruneTime = 336
      }
      service = {
        enabled = true
        name    = "http"
        port    = 5678
        type    = "ClusterIP"
      }
      nodeSelector = {
        "kubernetes.io/hostname" = "k8s"
      }
      timezone = "America/Los_Angeles"

      # Encryption key configuration
      encryptionKey = {
        existingSecret    = kubernetes_secret.n8n.metadata[0].name
        existingSecretKey = "N8N_ENCRYPTION_KEY"
      }

      # Fixed ingress configuration
      ingress = {
        enabled   = true
        className = var.ingress_class_name
      }
    })
  ]

  depends_on = [
    kubernetes_secret.n8n
  ]
}
