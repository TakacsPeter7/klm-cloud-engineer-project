resource "google_sql_database_instance" "postgres" {
  name             = "notes-api-db"
  database_version = "POSTGRES_15"
  region           = var.region
  deletion_protection = false

  settings {
    tier                        = "db-f1-micro"
    availability_type          = "ZONAL"
    disk_type                  = "PD_SSD"
    disk_size                  = 20
    disk_autoresize            = true
    disk_autoresize_limit      = 100
    
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      require_ssl = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "database" {
  name     = "notesdb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "users" {
  name     = "api-user"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}
