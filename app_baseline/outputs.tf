#
# Output the information required to test the
# environment created in main.tf (app_baseline)
#
output "dev_vpc_id" {
  description = "ID of dev VPC"
  value       = alicloud_vpc.dev_vpc.id
}

output "uat_vpc_id" {
  description = "ID of uat VPC"
  value       = alicloud_vpc.uat_vpc.id
}

output "prod_vpc_id" {
  description = "ID of prod VPC"
  value       = alicloud_vpc.prod_vpc.id
}

output "uid" {
  description = "UID of app account"
  value       = data.alicloud_account.current.id
}

output "region" {
  description = "Current region"
  value       = data.alicloud_regions.current_region_ds.regions.0.id
}

output "env_name" {
  description = "Descriptor for this sub account"
  value       = var.env_name
}
