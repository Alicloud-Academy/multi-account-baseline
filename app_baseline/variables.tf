#
# Variables used in main.tf (app_baseline)
#

# Application ID number, due to constraints in the current code,
# this MUST be a unique number for each deployed app, and MUST
# be between 0 and 4 (inclusive)
#
# Note: this is due to a limitation in the number of
# reasonably-sized subnets available in the 172.16.0.0/12 
# block, which is used by default for the application accounts. 
# With some work, you could change this.
variable "app_id" {
  description = "ID number of the current application. This MUST be unique and cannot be the same as the number used for any other deployed application. I recommend starting from 0 and incrementing by 1 for each new deployed app. This variable has NO default and MUST be set by the user."
}

variable "env_name" {
  description = "Environment name, used in the ECS instance module to set up a custom LogService ID"
}

#
# CEN Configuration (CEN Grant for Shared Services account)
#
variable "shared_svc_cen_id" {
  description = "CEN Instance ID for the CEN under the Shared Services account"
}

variable "shared_svc_uid" {
  description = "Account ID (UID) for the Shared Services account"
}

# Root account UID (needed for authorizing RAM role access)
variable "root_uid" {
  description = "Account ID (UID) for the root account"
}

#
# VPC Configuration helpers
#
variable "cidr_block" {
  description = "CIDR block to use when creating VPCs (defaults to 172.16.0.0/12)"
  default     = "172.16.0.0/12"
}

variable "standard_subnets" {
  description = "Standard subnets to deploy under each new VPC group"
  default     = ["portal", "application", "rds"]
}

variable "dev_vpc_redundancy" {
  description = "Number of AZs to span, for Dev subnet"
  default     = 1
}

variable "uat_vpc_redundancy" {
  description = "Number of AZs to span, for UAT subnet"
  default     = 2
}

variable "prod_vpc_redundancy" {
  description = "Number of AZs to span, for Prod(uction) subnet"
  default     = 3
}
