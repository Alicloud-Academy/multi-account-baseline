#
# Variables used in main.tf (shared_services)
#

# Root account UID (needed for authorizing RAM role access)
variable "root_uid" {
  description = "Account ID (UID) for the root account"
}

# VPC ID and UID information for application accounts,
# passed in from the root module
variable "subaccount_info" {}

variable "env_name" {
  description = "Environment name, used in the ECS instance module to set up a custom LogService ID"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the new shared services VPC group (defaults to 192.168.0.0/16)"
  default     = "192.168.0.0/16"
}

variable "num_subnets" {
  description = "Number of subnets (defaults to 2, can be any number between 1 and N, where N is the number of available AZs in your selected region)"
  default     = 2
}
