#
# Variables used in main.tf (root)
#

###
# Account ID number (UID)
###
variable "root_uid" {
  description = "The root account's UID (account ID)"
}

###
# Region, subnet, and CIDR configuration
###

variable "region" {
  description = "The Alibaba Cloud region you will use (defaults to Hangzhou)"
  default     = "cn-hangzhou"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the new shared services VPC group (defaults to 192.168.0.0/16)"
  default     = "192.168.0.0/16"
}

variable "num_subnets" {
  description = "Number of subnets (defaults to 2, can be any number between 1 and N, where N is the number of available AZs in your selected region)"
  default     = 2
}

###
# Access Keys and Secrets
###
variable "root_account_creds" {
  description = "Root account credentials (the root account is the account under which the Resource Directory Organization and Accounts are created)"
}

variable "shared_account_uid" {
  description = "UID of Shared Services account"
}

###
# RAM account login information
###

variable "ram_signin_page" {
  description = "URL for RAM sign in page"
  default     = "https://signin.aliyun.com/login.htm"
}

variable "ram_alias_postfix" {
  description = "The last part of any RAM sign-on name"
  default     = "onaliyun.com"
}

#
# Application account profiles (add new variables here as you add application accounts)
#

variable "app0_uid" {
  description = "UID of app0 account"
}

variable "app1_uid" {
  description = "UID of app0 account"
}

variable "app2_uid" {
  description = "UID of app0 account"
}

# variable "appN_uid" {
#   description = "UID of appN account"
# }
