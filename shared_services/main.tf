#
# Shared Services Account Configuration (shared_services)
#
# Author: Jeremy Pedersen
# Created 2019-09-24
# Updated: 2021-05-11

# Get account metadata (needed to output UID for subaccount CEN grants)
data "alicloud_account" "current" {}

# Get current region
data "alicloud_regions" "current_region_ds" {
  current = true
}

# Get a list of AZs
data "alicloud_zones" "abc_zones" {
  multi = true
}

# Create the shared services VPC group
resource "alicloud_vpc" "shared-services-vpc" {
  vpc_name   = "shared_services"
  cidr_block = var.vpc_cidr_block
}

# Create subnet groups for hosting shared services (such as MS AD)
resource "alicloud_vswitch" "subnet" {

  count = var.num_subnets # Could be up to N, where N is the number of AZs in your selected region

  vswitch_name = "subnet_${count.index}"

  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  zone_id    = element(data.alicloud_zones.abc_zones.zones.*.id, count.index)
  vpc_id     = alicloud_vpc.shared-services-vpc.id
}

# Create CEN Instance
resource "alicloud_cen_instance" "shared_svc_cen" {
  cen_instance_name = "shared_svc_cen"
}

#
# Create VPC Attachments for Application Accounts (CEN)
#

# First, attach the Shared Services VPC to the new CEN instance
resource "alicloud_cen_instance_attachment" "shared_services_vpc_attachment" {
  instance_id              = alicloud_cen_instance.shared_svc_cen.id
  child_instance_id        = alicloud_vpc.shared-services-vpc.id
  child_instance_type      = "VPC"
  child_instance_region_id = data.alicloud_regions.current_region_ds.regions.0.id
}

###
# Application account VPC attachments
# 
# WARNING: Code below makes some assumptions about how output variables
# are named in the app_baseline module. Specifically, it expects to 
# find output variables named:
# 1) dev_vpc_id
# 2) uat_vpd_id
# 3) prod_vpc_id
###

# Attach Application account "Dev" VPCs
resource "alicloud_cen_instance_attachment" "application_attachments_dev" {
  count = length(var.subaccount_info)

  # Shared Account Info
  instance_id = alicloud_cen_instance.shared_svc_cen.id

  # Child Account Info
  child_instance_id        = element(var.subaccount_info, count.index).dev_vpc_id
  child_instance_region_id = element(var.subaccount_info, count.index).region
  child_instance_type      = "VPC"
  child_instance_owner_id  = element(var.subaccount_info, count.index).uid

}

# Attach Application account "UAT" VPCs
resource "alicloud_cen_instance_attachment" "application_attachments_uat" {
  count = length(var.subaccount_info)

  # Shared Account Info
  instance_id = alicloud_cen_instance.shared_svc_cen.id

  # Child Account Info
  child_instance_id        = element(var.subaccount_info, count.index).uat_vpc_id
  child_instance_region_id = element(var.subaccount_info, count.index).region
  child_instance_type      = "VPC"
  child_instance_owner_id  = element(var.subaccount_info, count.index).uid

  depends_on = [
    alicloud_cen_instance.shared_svc_cen
  ]
}

# Attach Application account "Prod" VPCs
resource "alicloud_cen_instance_attachment" "application_attachments_prod" {
  count = length(var.subaccount_info)

  # Shared Account Info
  instance_id = alicloud_cen_instance.shared_svc_cen.id

  # Child Account Info
  child_instance_id        = element(var.subaccount_info, count.index).prod_vpc_id
  child_instance_region_id = element(var.subaccount_info, count.index).region
  child_instance_type      = "VPC"
  child_instance_owner_id  = element(var.subaccount_info, count.index).uid

  depends_on = [
    alicloud_cen_instance.shared_svc_cen
  ]
}

###
# RAM role configuration
###
module "ram_audit_role" {
  source   = "../ram_audit_role"
  root_uid = var.root_uid
}

module "ram_billing_role" {
  source   = "../ram_billing_role"
  root_uid = var.root_uid
}

module "ram_admin_role" {
  source   = "../ram_admin_role"
  root_uid = var.root_uid
}

# Configure policy for SLS cross-account audit access
module "sub_actiontrail" {
  source   = "../sub_actiontrail"
  root_uid = var.root_uid
}
