# Terraform configuration for PetNow Dogs - Google Cloud Infrastructure
# Author: PetNow-Dogs Team

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Configure the Google Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Variables
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Cloud SQL Instance
resource "google_sql_database_instance" "petnow_dogs_db" {
  name             = "petnow-dogs-${var.environment}-db"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier = var.environment == "prod" ? "db-n1-standard-2" : "db-f1-micro"
    
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    maintenance_window {
      day          = 7  # Sunday
      hour         = 3  # 3 AM
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"  # WARNING: Change this for production
      }
    }

    disk_size = 10
    disk_type = "PD_SSD"
  }

  deletion_protection = var.environment == "prod"

  depends_on = [google_project_service.required_apis]
}

# Databases for each microservice
resource "google_sql_database" "databases" {
  for_each = toset([
    "auth_service_db",
    "owner_service_db", 
    "pet_service_db",
    "alert_service_db",
    "scan_service_db"
  ])

  name     = each.value
  instance = google_sql_database_instance.petnow_dogs_db.name
}

# Users for each microservice
resource "google_sql_user" "service_users" {
  for_each = {
    auth_user   = "auth_service_db"
    owner_user  = "owner_service_db"
    pet_user    = "pet_service_db"
    alert_user  = "alert_service_db"
    scan_user   = "scan_service_db"
  }

  name     = each.key
  instance = google_sql_database_instance.petnow_dogs_db.name
  password = random_password.service_passwords[each.key].result
}

# Generate random passwords
resource "random_password" "service_passwords" {
  for_each = toset([
    "auth_user",
    "owner_user", 
    "pet_user",
    "alert_user",
    "scan_user"
  ])

  length  = 16
  special = true
}

# Cloud Storage Bucket for images
resource "google_storage_bucket" "petnow_images" {
  name          = "petnow-dogs-images-${var.project_id}"
  location      = var.region
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 365  # Delete objects older than 1 year
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.required_apis]
}

# IAM for Cloud Storage
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.petnow_images.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Cloud Run service for AI Service
resource "google_cloud_run_service" "ai_service" {
  name     = "petnow-ai-service"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/ai-service:latest"
        
        ports {
          container_port = 8000
        }

        env {
          name  = "DATABASE_URL"
          value = "postgresql://${google_sql_user.service_users["scan_user"].name}:${google_sql_user.service_users["scan_user"].password}@${google_sql_database_instance.petnow_dogs_db.ip_address[0].ip_address}:5432/${google_sql_database.databases["scan_service_db"].name}"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.required_apis]
}

# Outputs
output "database_instance_name" {
  value = google_sql_database_instance.petnow_dogs_db.name
}

output "database_connection_name" {
  value = google_sql_database_instance.petnow_dogs_db.connection_name
}

output "database_ip_address" {
  value = google_sql_database_instance.petnow_dogs_db.ip_address[0].ip_address
}

output "storage_bucket_name" {
  value = google_storage_bucket.petnow_images.name
}

output "ai_service_url" {
  value = google_cloud_run_service.ai_service.status[0].url
}

output "database_passwords" {
  value = {
    for user, password in random_password.service_passwords : user => password.result
  }
  sensitive = true
} 