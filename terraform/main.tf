terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "kind-kind"
}

# Manage the existing Kubernetes Deployment
resource "kubernetes_deployment" "devops_app" {
  metadata {
    name = "devops-app"

    labels = {
      app = "devops-app"
    }
  }

  wait_for_rollout = true

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "devops-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "devops-app"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name              = "devops-app"
          image             = "devops-mini-project:v1"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 5000
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# Manage the existing Kubernetes Service
resource "kubernetes_service" "devops_service" {
  metadata {
    name = "devops-service"
  }

  wait_for_load_balancer = false

  spec {
    type = "NodePort"

    selector = {
      app = "devops-app"
    }

    port {
      port        = 5000
      target_port = 5000
      node_port   = 30080
    }
  }
}