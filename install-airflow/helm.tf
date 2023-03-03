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


resource "helm_release" "airflow" {
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  name       = "airflow"
  version    = "1.7.0"
  namespace  = "default"
  values     = [file("airflow-values.yaml")]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}


# resource "kubernetes_service" "example" {
#   metadata {
#     name = "example"
#   }
#   spec {
#     port {
#       port        = 8080
#       target_port = 80
#     }
#     type = "LoadBalancer"
#   }
# }

# # Create a local variable for the load balancer name.
# locals {
#   lb_name = split("-", split(".", kubernetes_service.example.status.0.load_balancer.0.ingress.0.hostname).0).0
# }

# # Read information about the load balancer using the AWS provider.
# data "aws_elb" "example" {
#   name = local.lb_name
# }

# output "load_balancer_name" {
#   value = local.lb_name
# }

# output "load_balancer_hostname" {
#   value = kubernetes_service.example.status.0.load_balancer.0.ingress.0.hostname
# }

# output "load_balancer_info" {
#   value = data.aws_elb.example
# }