#
# Alibaba Cloud Multi-Account Baseline Root Module (root)
#
# 1 - Configured shared services and application accounts
# 2 - Enables and configures cross-account logging
# 3 - Creates RAM accounts and associated Roles + Policies
#
# Author: Jeremy Pedersen
# Created 2019-09-24
# Updated: 2020-09-24

#############################
# Stuff that doesn't change #
#############################

###
# Configure root account and associated RAM accounts
###

# Root account (logging, bill payment)
provider "alicloud" {
  alias   = "root"
  access_key = var.root_account_creds.ak
  secret_key = var.root_account_creds.secret
  region  = var.region
}

###
# Generate random passwords
###

# Admin RAM account

resource "random_password" "ram_admin" {
  length  = 20
  special = true
}

# Audit RAM account
resource "random_password" "ram_audit" {
  length  = 20
  special = true
}

# Billing RAM account
resource "random_password" "ram_billing" {
  length  = 20
  special = true
}

# ECS Login password
resource "random_password" "ecs_password" {
  length  = 10
  special = true
}

###
# Configure RAM Accounts under the root account
###

module "admin_ram" {
  source = "./ram_admin"
  providers = {
    alicloud = alicloud.root
  }
  account_name         = "administrator"
  account_display_name = "administrator"
  password             = random_password.ram_admin.result
}

module "audit_ram" {
  source = "./ram_audit"
  providers = {
    alicloud = alicloud.root
  }
  account_name         = "audit"
  account_display_name = "audit"
  password             = random_password.ram_audit.result
}

module "billing_ram" {
  source = "./ram_billing"
  providers = {
    alicloud = alicloud.root
  }
  account_name         = "billing"
  account_display_name = "billing"
  password             = random_password.ram_billing.result
}

###
# Configure shared account
###

# Shared account (shared services, network interconnect)
provider "alicloud" {
  alias   = "shared"
  access_key = var.shared_account_creds.ak
  secret_key = var.shared_account_creds.secret
  region  = var.region
}

module "shared_svc_baseline" {
  source = "./shared_services"
  providers = {
    alicloud = alicloud.shared
  }

  env_name = "shared_svc"

  # UID for granting RAM role access from root account
  root_uid = var.root_uid

  # Subaccount information for app accounts
  # (needed to create CEN bindings)
  subaccount_info = local.subaccount_info
}

### 
# Log Services Configuration
###

# ActionTrail Configuration
module "root_actiontrail" {
  source = "./root_actiontrail"
  providers = {
    alicloud = alicloud.root
  }
  # WARNING: Don't forget to add IDs for each new account you create in your organization
  account_ids = local.account_ids
}

# ECS Log Collection Configuration
module "system_logs" {
  source = "./system_logs"
  providers = {
    alicloud = alicloud.root
  }

  root_uid = var.root_uid

  # A list of all the environment IDs used by each subaccount 
  machine_identity_list = local.machine_identity_list
}

######################
# Stuff that changes #
######################

###
# Configure application accounts
### 

# Application account providers
provider "alicloud" {
  alias   = "app0"
  access_key = var.app0_creds.ak
  secret_key = var.app0_creds.secret
  region  = var.region
}

module "app0_baseline" {
  source = "./app_baseline"
  providers = {
    alicloud = alicloud.app0
  }

  # Application ID (a number from 0 to 4, unique for each app account)
  app_id   = 0
  env_name = "app0"
  # CEN information (to authorize CEN bindings)
  shared_svc_cen_id = module.shared_svc_baseline.cen_id
  shared_svc_uid    = module.shared_svc_baseline.uid
  # UID for granting RAM role access from root account
  root_uid = var.root_uid
}

###
# Configure app1 account
###

# Application accounts
provider "alicloud" {
  alias   = "app1"
  access_key = var.app1_creds.ak
  secret_key = var.app1_creds.secret
  region  = var.region
}

module "app1_baseline" {
  source = "./app_baseline"
  providers = {
    alicloud = alicloud.app1
  }

  # Application ID (a number from 0 to 4, unique for each app account)
  app_id   = 1
  env_name = "app1"
  # CEN information (to authorize CEN bindings)
  shared_svc_cen_id = module.shared_svc_baseline.cen_id
  shared_svc_uid    = module.shared_svc_baseline.uid

  # UID for granting RAM role access from root account
  root_uid = var.root_uid
}

##########################################
### INSERT ADDITIONAL APP MODULES HERE ###
##########################################

###
# Configure ECS Instances
# 
# These instances help us to test the network environment
# and generate some logs and metrics to ensure our log and
# audit configurations are working properly
###

# module "ecs_testbed_shared" {
#   source = "./ecs_testbed"
#   providers = {
#     alicloud = alicloud.shared
#   }
#   env_name = module.shared_svc_baseline.env_name
#   root_uid = var.root_uid
#   password = random_password.ecs_password.result
# }

# module "ecs_testbed_app0" {
#   source = "./ecs_testbed"
#   providers = {
#     alicloud = alicloud.app0
#   }
#   env_name = module.app0_baseline.env_name
#   root_uid = var.root_uid
#   password = random_password.ecs_password.result
# }

# module "ecs_testbed_app1" {
#   source = "./ecs_testbed"
#   providers = {
#     alicloud = alicloud.app1
#   }
#   env_name = module.app1_baseline.env_name
#   root_uid = var.root_uid
#   password = random_password.ecs_password.result
# }

###################
# Local Variables #
###################

# The variables should be updated whenever new subaccounts are added
locals {
  subaccount_info = [
    # App 0
    {
      uid         = module.app0_baseline.uid
      region      = module.app0_baseline.region
      dev_vpc_id  = module.app0_baseline.dev_vpc_id
      uat_vpc_id  = module.app0_baseline.uat_vpc_id
      prod_vpc_id = module.app0_baseline.prod_vpc_id
    },
    # App 1
    {
      uid         = module.app1_baseline.uid
      region      = module.app1_baseline.region
      dev_vpc_id  = module.app1_baseline.dev_vpc_id
      uat_vpc_id  = module.app1_baseline.uat_vpc_id
      prod_vpc_id = module.app1_baseline.prod_vpc_id
    }
    # UPDATE: Insert additional application configurations here
  ]
}

locals {
  account_ids = [
    module.shared_svc_baseline.uid,
    module.app0_baseline.uid,
    module.app1_baseline.uid
    # UPDATE: Insert additional module configurations here
  ]
}
locals {
  machine_identity_list = [
    module.shared_svc_baseline.env_name,
    module.app0_baseline.env_name,
    module.app1_baseline.env_name
    # UPDATE: Insert additional module configurations here
  ]
}
