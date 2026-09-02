terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Connects directly to K8s on 192.168.1.184
provider "kubernetes" {
  config_path = "~/.kube/config" 
}

resource "kubernetes_namespace" "prod_env" {
  metadata {
    name = "enterprise-app-prod"
  }
}
