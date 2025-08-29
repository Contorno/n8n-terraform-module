resource "kubernetes_ingress_v1" "n8n" {
  metadata {
    name      = "${var.name}-tailscale"
    namespace = kubernetes_namespace.n8n.metadata[0].name
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