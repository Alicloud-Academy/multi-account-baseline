# Output information needed to log into RAM (ram_admin)
output "ram_login_name" {
  description = "RAM account login name"
  value       = alicloud_ram_login_profile.ram-admin-profile.user_name
}

output "ram_login_password" {
  description = "RAM account password"
  value       = alicloud_ram_login_profile.ram-admin-profile.password
  sensitive   = true
}

output "ram_login_alias" {
  description = "RAM acocunt alias"
  value       = data.alicloud_ram_account_aliases.ram_alias.account_alias
}

output "role_name" {
  description = "Name of RAM role"
  value       = var.role_name
}
