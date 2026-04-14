data "ns_connection" "notification" {
  name     = "notification"
  contract = "datastore/gcp/notification"
  optional = true
}

locals {
  notification_name = try(data.ns_connection.notification.outputs.notification_name, "")

  instance_name = google_memorystore_instance.this.instance_id
}

# CPU Utilization Alert
resource "google_monitoring_alert_policy" "valkey_cpu" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Valkey CPU Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization > ${var.resource_thresholds.cpu}%"

    condition_threshold {
      filter          = "resource.type=\"memorystore.googleapis.com/Instance\" AND resource.labels.instance_id=\"${local.instance_name}\" AND metric.type=\"memorystore.googleapis.com/instance/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.cpu / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Valkey instance ${local.instance_name} CPU utilization exceeded ${var.resource_thresholds.cpu}%. Consider scaling up the node type or adding shards."
    mime_type = "text/markdown"
  }
}

# Memory Utilization Alert
resource "google_monitoring_alert_policy" "valkey_memory" {
  count = local.notification_name == "" ? 0 : 1

  project      = local.project_id
  display_name = "Valkey Memory Utilization High"
  combiner     = "OR"

  conditions {
    display_name = "Memory utilization > ${var.resource_thresholds.memory}%"

    condition_threshold {
      filter          = "resource.type=\"memorystore.googleapis.com/Instance\" AND resource.labels.instance_id=\"${local.instance_name}\" AND metric.type=\"memorystore.googleapis.com/instance/memory/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.resource_thresholds.memory / 100

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [local.notification_name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Valkey instance ${local.instance_name} memory utilization exceeded ${var.resource_thresholds.memory}%. Consider scaling up the node type, adding shards, or reviewing the eviction policy."
    mime_type = "text/markdown"
  }
}
