variable "region" {
  type        = string
  description = "GCP Region"
}

variable "project_id" {
  type        = string
  description = "GCP Project Id"
}

variable "node_pool_machine_type" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "node_pool_version" {
  type = string
}