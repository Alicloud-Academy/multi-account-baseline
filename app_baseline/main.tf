#
# Application Account Baseline (app_baseline)
#
# Author: Jeremy Pedersen
# Created 2019-09-24
# Updated: 2021-05-11

# Data source used to determine current account ID
data "alicloud_account" "current" {}

# Determine current region

data "alicloud_regions" "current_region_ds" {
  current = true
}

# Get a list of availability zones
data "alicloud_zones" "abc_zones" {
  multi = true
}

# 
# VPC Group Configuration
#
# Note: "var.app_id*3" makes sure we start our new VPC address ranges
# above the ranges taken up by the last 3 VPCs (which may be occupied by previously created apps with lower app ID numbers)
resource "alicloud_vpc" "dev_vpc" {
  vpc_name   = "dev_vpc"
  cidr_block = cidrsubnet(var.cidr_block, 4, var.app_id * 3 + 0)
}

resource "alicloud_vpc" "uat_vpc" {
  vpc_name   = "uat_vpc"
  cidr_block = cidrsubnet(var.cidr_block, 4, var.app_id * 3 + 1)
}

resource "alicloud_vpc" "prod_vpc" {
  vpc_name   = "prod_vpc"
  cidr_block = cidrsubnet(var.cidr_block, 4, var.app_id * 3 + 2)
}

#
# VSwitch Configuration
#
# Note: the math being done inside cidrsubnet() might look a little complex, but 
# the goal is straightforward: we are trying evenly partition the IP address space
# used by our Prod, UAT, and Dev VSwitches.  
resource "alicloud_vswitch" "dev_vswitches" {
  count = length(var.standard_subnets) * var.dev_vpc_redundancy

  vswitch_name = "app_${var.app_id}_dev_${var.standard_subnets[floor(count.index / var.dev_vpc_redundancy)]}_subnet_${count.index % var.dev_vpc_redundancy}"
  cidr_block   = cidrsubnet(alicloud_vpc.dev_vpc.cidr_block, 8, count.index)

  vpc_id  = alicloud_vpc.dev_vpc.id
  zone_id = element(data.alicloud_zones.abc_zones.zones.*.id, count.index % var.dev_vpc_redundancy)

}

resource "alicloud_vswitch" "uat_vswitches" {
  count = length(var.standard_subnets) * var.uat_vpc_redundancy

  vswitch_name = "app_${var.app_id}_uat_${var.standard_subnets[floor(count.index / var.uat_vpc_redundancy)]}_subnet_${count.index % var.uat_vpc_redundancy}"
  cidr_block   = cidrsubnet(alicloud_vpc.uat_vpc.cidr_block, 8, count.index)

  vpc_id  = alicloud_vpc.uat_vpc.id
  zone_id = element(data.alicloud_zones.abc_zones.zones.*.id, count.index % var.uat_vpc_redundancy)

}

resource "alicloud_vswitch" "prod_vswitches" {
  count = length(var.standard_subnets) * var.prod_vpc_redundancy

  vswitch_name = "app_${var.app_id}_prod_${var.standard_subnets[floor(count.index / var.prod_vpc_redundancy)]}_subnet_${count.index % var.prod_vpc_redundancy}"
  cidr_block   = cidrsubnet(alicloud_vpc.prod_vpc.cidr_block, 8, count.index)

  vpc_id  = alicloud_vpc.prod_vpc.id
  zone_id = element(data.alicloud_zones.abc_zones.zones.*.id, count.index % var.prod_vpc_redundancy)

}

#
# CEN Grant Configuration (this will give the CEN instance under the Shared Services
# account the permissions it needs to add our Prod, UAT, and Dev VPCs into the network)
#
resource "alicloud_cen_instance_grant" "dev_vpc_cen_grant" {
  cen_id            = var.shared_svc_cen_id
  child_instance_id = alicloud_vpc.dev_vpc.id
  cen_owner_id      = var.shared_svc_uid
}

resource "alicloud_cen_instance_grant" "uat_vpc_cen_grant" {
  cen_id            = var.shared_svc_cen_id
  child_instance_id = alicloud_vpc.uat_vpc.id
  cen_owner_id      = var.shared_svc_uid
}

resource "alicloud_cen_instance_grant" "prod_vpc_cen_grant" {
  cen_id            = var.shared_svc_cen_id
  child_instance_id = alicloud_vpc.prod_vpc.id
  cen_owner_id      = var.shared_svc_uid
}

###
# RAM role configuration (this will allow RAM users under the master (root) account
# to access the application account)
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

# Configure policy for SLS cross-account audit access (this will allow Log Service
# under the root account to collect logs from the application account)
module "sub_actiontrail" {
  source   = "../sub_actiontrail"
  root_uid = var.root_uid
}
