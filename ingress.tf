resource "kubernetes_ingress_v1" "n8n_tailscale" {
  metadata {
    name      = "${var.name}-tailscale"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "tailscale"

    default_backend {
      service {
        name = kubernetes_service.n8n.metadata[0].name
        port {
          number = 5678
        }
      }
    }

    tls {
      hosts = ["n8n"]
    }
  }
}

resource "kubernetes_ingress_v1" "n8n_webhooks" {
  metadata {
    name      = "${var.name}-webhooks"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer"                    = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"          = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts = [var.n8n_webhook_host]
    }

    rule {
      host = var.n8n_webhook_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.n8n.metadata[0].name
              port {
                number = 5678
              }
            }
          }
        }
      }
    }
  }
}
