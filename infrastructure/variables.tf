variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "eu-west1"
}

variable "image_url" {
  description = "Docker image URL"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "db_tier" {
  description = "The machine type for the Cloud SQL instance."
  type        = string
  default     = "db-f1-micro"
}

variable "db_user" {
  description = "The username for the Cloud SQL database."
  type        = string
  default     = "api-user"
}

variable "db_name" {
  description = "The name of the Cloud SQL database."
  type        = string
  default     = "notesdb"
}

variable "cloud_run_max_instances" {
  description = "The maximum number of instances for the Cloud Run service."
  type        = number
  default     = 10
}
