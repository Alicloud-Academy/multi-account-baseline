#
# Output the information required to test the
# environment created in main.tf (shared_services)
#
output "cen_id" {
  description = "ID of Shared Services CEN instance"
  value       = alicloud_cen_instance.shared_svc_cen.id
}

output "uid" {
  description = "UID of Shared Services account"
  value       = data.alicloud_account.current.id
}

output "env_name" {
  description = "Descriptor for this sub account"
  value       = var.env_name
}
