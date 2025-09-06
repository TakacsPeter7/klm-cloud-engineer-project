terraform {
  required_version = "~> 1.13.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "klm-demo"
    prefix = "notes-api/terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
