provider "google" {
  version = "3.33.0"
}

resource "google_project_service" "gke_api" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_dependent_services = true
}

resource "google_container_cluster" "demo_app_cluster" {
  project                  = var.project_id
  name                     = "demo-app"
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = var.cluster_version

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  depends_on = [
    google_project_service.gke_api
  ]
}

resource "google_container_node_pool" "demo_app_node_pool" {
  project    = var.project_id
  name       = "demo-app"
  location   = var.region
  cluster    = google_container_cluster.demo_app_cluster.name
  node_count = 1
  version    = var.node_pool_version

  node_config {
    disk_size_gb = 10
    machine_type = var.node_pool_machine_type
    metadata     = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

  }

  management {
    auto_repair  = false
    auto_upgrade = false
  }
}