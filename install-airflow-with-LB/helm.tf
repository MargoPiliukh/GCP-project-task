terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.52"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
} 

data "google_client_config" "default" {}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.test-gke-cluster.endpoint}"
  zone = "europe-west1"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.test-gke-cluster.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_service" "airflow" {
  for_each = toset(var.AIRFLOW_TAGS)
  metadata {
    namespace   = replace(each.value, ".", "-")
    name        = "airflow-${var.PROJECT_ENV}-${index(var.AIRFLOW_TAGS, each.value) + 1}-web-lb"
    annotations = {
      "cloud.google.com/load-balancer-type": "Internal"
    }
  }

  spec {
    selector         = {
      "release" = "airflow"
      "component": "web"
    }
    session_affinity = "ClientIP"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type             = "LoadBalancer"
  }
}
