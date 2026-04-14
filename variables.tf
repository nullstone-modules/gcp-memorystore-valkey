variable "valkey_version" {
  type        = string
  default     = "8.0"
  description = <<EOF
Specify the Valkey engine version to use.
Supported versions are 7.2 and 8.0.
By default, configured with 8.0.
EOF
}

variable "node_type" {
  type        = string
  default     = "SHARED_CORE_NANO"
  description = <<EOF
The node type used to provision the Valkey instance.
By default, configured with SHARED_CORE_NANO.
Available options:
SHARED_CORE_NANO
STANDARD_SMALL
HIGHMEM_MEDIUM
HIGHMEM_XLARGE
EOF

  validation {
    condition     = contains(["SHARED_CORE_NANO", "STANDARD_SMALL", "HIGHMEM_MEDIUM", "HIGHMEM_XLARGE"], var.node_type)
    error_message = "node_type must be one of: SHARED_CORE_NANO, STANDARD_SMALL, HIGHMEM_MEDIUM, HIGHMEM_XLARGE"
  }
}

variable "shard_count" {
  type        = number
  default     = 1
  description = <<EOF
The number of shards for the Valkey instance.
By default, configured with 1. Increase this to horizontally scale the instance.
EOF
}

variable "replica_count" {
  type        = number
  default     = 0
  description = <<EOF
The number of replica nodes per shard.
By default, configured with 0. For high availability, set this to 1 or 2.
EOF
}

variable "mode" {
  type        = string
  default     = "CLUSTER_DISABLED"
  description = <<EOF
The deployment mode for the Valkey instance.
CLUSTER_DISABLED mode runs the instance in a non-clustered mode (single shard).
CLUSTER mode runs the instance in clustered mode across multiple shards.
STANDALONE mode runs a single standalone node.
By default, configured with CLUSTER_DISABLED.
EOF

  validation {
    condition     = contains(["STANDALONE", "CLUSTER", "CLUSTER_DISABLED"], var.mode)
    error_message = "mode must be one of: STANDALONE, CLUSTER, CLUSTER_DISABLED"
  }
}

variable "transit_encryption" {
  type        = bool
  default     = false
  description = <<EOF
When enabled, in-transit communications to the Valkey instance will require TLS.
By default, this is disabled.
EOF
}

variable "authorization_mode" {
  type        = string
  default     = "DISABLED"
  description = <<EOF
The authorization mode for the Valkey instance.
DISABLED => No authorization is required to access the instance.
IAM_AUTH => Clients must authenticate using GCP IAM credentials.
By default, this is set to DISABLED.
EOF

  validation {
    condition     = contains(["DISABLED", "IAM_AUTH"], var.authorization_mode)
    error_message = "authorization_mode must be one of: DISABLED, IAM_AUTH"
  }
}

variable "persistence_mode" {
  type        = string
  default     = "DISABLED"
  description = <<EOF
Configures data persistence for the Valkey instance.
DISABLED => No data persistence.
RDB => Snapshot-based persistence with a configurable interval.
AOF => Append-only file persistence for stronger durability.
By default, this is set to DISABLED.
EOF

  validation {
    condition     = contains(["DISABLED", "RDB", "AOF"], var.persistence_mode)
    error_message = "persistence_mode must be one of: DISABLED, RDB, AOF"
  }
}

variable "rdb_snapshot_period" {
  type        = string
  default     = "ONE_HOUR"
  description = <<EOF
Configures how often RDB snapshots are taken.
Only applicable when persistence_mode is RDB.
Available options: ONE_HOUR, SIX_HOURS, TWELVE_HOURS, TWENTY_FOUR_HOURS.
By default, configured with ONE_HOUR.
EOF

  validation {
    condition     = contains(["ONE_HOUR", "SIX_HOURS", "TWELVE_HOURS", "TWENTY_FOUR_HOURS"], var.rdb_snapshot_period)
    error_message = "rdb_snapshot_period must be one of: ONE_HOUR, SIX_HOURS, TWELVE_HOURS, TWENTY_FOUR_HOURS"
  }
}

variable "aof_append_fsync" {
  type        = string
  default     = "EVERY_SEC"
  description = <<EOF
Configures the fsync policy for AOF persistence.
Only applicable when persistence_mode is AOF.
Available options: NO, EVERY_SEC, ALWAYS.
By default, configured with EVERY_SEC.
EOF

  validation {
    condition     = contains(["NO", "EVERY_SEC", "ALWAYS"], var.aof_append_fsync)
    error_message = "aof_append_fsync must be one of: NO, EVERY_SEC, ALWAYS"
  }
}

variable "engine_configs" {
  type        = map(string)
  default     = {}
  description = <<EOF
A dictionary of engine configuration overrides for the Valkey instance.
For a list of supported configuration parameters, see https://cloud.google.com/memorystore/docs/valkey/supported-engine-configurations
EOF
}

variable "resource_thresholds" {
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 80
    memory = 85
  }

  description = <<EOF
Enables alerts on resource usage for the Valkey instance.

Each alert is configured to trigger when the resource usage exceeds the specified threshold.
The thresholds are specified as percentages. (i.e. 80 => 80%)
EOF
}
