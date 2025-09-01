terraform {
  required_version = ">= 1.12.2"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.15.28"
    }
  }
}
