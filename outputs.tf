output "instance_name" {
  value       = google_memorystore_instance.this.instance_id
  description = "string ||| Name of the Valkey instance"
}

output "instance_id" {
  value       = google_memorystore_instance.this.id
  description = "string ||| The fully-qualified resource id of the Valkey instance"
}

output "db_protocol" {
  value       = local.valkey_scheme
  description = "string ||| This emits `rediss` (secure) or `redis` and enables/disables transit encryption."
}

output "db_endpoint" {
  value       = local.valkey_endpoint
  description = "string ||| The endpoint URL (host:port) to access the Valkey instance"
}

output "host" {
  value       = local.valkey_host
  description = "string ||| The host address used to connect to the Valkey instance"
}

output "port" {
  value       = local.valkey_port
  description = "number ||| The port used to connect to the Valkey instance"
}

output "authorization_mode" {
  value       = local.authorization_mode
  description = "string ||| The authorization mode configured on the Valkey instance"
}
