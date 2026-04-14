locals {
  valkey_location         = data.google_compute_subnetwork.private0.region
  transit_encryption_mode = var.transit_encryption ? "SERVER_AUTHENTICATION" : "TRANSIT_ENCRYPTION_DISABLED"
  authorization_mode      = var.authorization_mode == "IAM_AUTH" ? "IAM_AUTH" : "AUTH_DISABLED"
}

resource "google_network_connectivity_service_connection_policy" "this" {
  name          = "${local.resource_name}-valkey-pscp"
  location      = local.valkey_location
  service_class = "gcp-memorystore"
  description   = "PSC connection policy for ${local.block_name} Valkey instance"
  network       = local.vpc_id
  labels        = local.labels

  psc_config {
    subnetworks = [data.google_compute_subnetwork.private0.id]
  }

  depends_on = [google_project_service.networkconnectivity]
}

resource "google_memorystore_instance" "this" {
  instance_id             = local.resource_name
  location                = local.valkey_location
  engine_version          = "VALKEY_${replace(var.valkey_version, ".", "_")}"
  node_type               = var.node_type
  shard_count             = var.shard_count
  replica_count           = var.replica_count
  mode                    = var.mode
  transit_encryption_mode = local.transit_encryption_mode
  authorization_mode      = local.authorization_mode
  engine_configs          = var.engine_configs
  labels                  = local.labels

  desired_auto_created_endpoints {
    project_id = local.project_id
    network    = local.vpc_id
  }

  persistence_config {
    mode = var.persistence_mode

    dynamic "rdb_config" {
      for_each = var.persistence_mode == "RDB" ? [true] : []

      content {
        rdb_snapshot_period = var.rdb_snapshot_period
      }
    }

    dynamic "aof_config" {
      for_each = var.persistence_mode == "AOF" ? [true] : []

      content {
        append_fsync = var.aof_append_fsync
      }
    }
  }

  depends_on = [
    google_project_service.memorystore,
    google_network_connectivity_service_connection_policy.this,
  ]
}

locals {
  endpoints      = google_memorystore_instance.this.endpoints
  psc_connection = try(local.endpoints[0].connections[0].psc_auto_connection[0], null)

  valkey_host     = try(local.psc_connection.ip_address, "")
  valkey_port     = try(local.psc_connection.port, 6379)
  valkey_endpoint = local.valkey_host == "" ? "" : "${local.valkey_host}:${local.valkey_port}"
  valkey_scheme   = var.transit_encryption ? "rediss" : "redis"
  valkey_url      = local.valkey_endpoint == "" ? "" : "${local.valkey_scheme}://${local.valkey_endpoint}"
}
