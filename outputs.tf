#
# Output the information required to test the
# environment created in main.tf (root)
#

#############################
# Stuff that doesn't change #
#############################

output "root_uid" {
  description = "UID of root account"
  value       = var.root_uid
}

###
# RAM Login information
###
output "ram_logon_url" {
  description = "URL for RAM user login"
  value       = var.ram_signin_page
}

output "ram_alias_postfix" {
  description = "Postfix for RAM user logons"
  value       = ".onaliyun.com"
}

output "admin_login" {
  description = "Login string for administrator RAM user"
  value       = "${module.admin_ram.ram_login_name}@${module.admin_ram.ram_login_alias}.${var.ram_alias_postfix}"
}

output "admin_password" {
  description = "Administrator RAM account password"
  value       = module.admin_ram.ram_login_password
  sensitive   = true
}

output "audit_login" {
  description = "Login string for audit RAM user"
  value       = "${module.audit_ram.ram_login_name}@${module.audit_ram.ram_login_alias}.${var.ram_alias_postfix}"
}

output "audit_password" {
  description = "Audit RAM account password"
  value       = module.audit_ram.ram_login_password
  sensitive   = true
}

output "billing_login" {
  description = "Login string for RAM user"
  value       = "${module.billing_ram.ram_login_name}@${module.billing_ram.ram_login_alias}.${var.ram_alias_postfix}"
}

output "billing_password" {
  description = "Administrator RAM account password"
  value       = module.billing_ram.ram_login_password
  sensitive   = true
}

###
# RAM Role information (needed when assuming RAM roles)
###

output "ram_role_billing_role_name" {
  description = "RAM role name to use when switching to the billing role"
  value       = module.billing_ram.role_name
}

output "ram_role_audit_role_name" {
  description = "RAM role name to use when switching to the audit role"
  value       = module.audit_ram.role_name
}

output "ram_role_admin_role_name" {
  description = "RAM role name to use when switching to the admin role"
  value       = module.admin_ram.role_name
}

######################
# Stuff that changes #
######################

###
# Domain Aliases (needed when assuming RAM roles)
###

output "ram_shared_svc_uid" {
  description = "shared services UID"
  value       = module.shared_svc_baseline.uid
}

# RAM information for the shared account and application accounts
output "ram_app0_uid" {
  description = "app0 UID"
  value       = module.app0_baseline.uid
}

output "ram_app1_uid" {
  description = "app1 UID"
  value       = module.app1_baseline.uid
}

###
# ECS login information
###

# # Shared Services
# output "ecs_shared_svc_public_ips" {
#   description = "Public IP addresses for shared_svc instance login"
#   value       = module.ecs_testbed_shared.ecs_public_ips
# }

# output "ecs_shared_svc_private_ips" {
#   description = "Private IP addresses for shared_svc instance login"
#   value       = module.ecs_testbed_shared.ecs_private_ips
# }

# # App 0
# output "ecs_app0_public_ips" {
#   description = "Public IP addresses for app0 instance login"
#   value       = module.ecs_testbed_app0.ecs_public_ips
# }

# output "ecs_app0_private_ips" {
#   description = "Private IP addresses for app0 instance login"
#   value       = module.ecs_testbed_app0.ecs_private_ips
# }

# # App 1
# output "ecs_app1_public_ips" {
#   description = "Public IP addresses for app1 instance login"
#   value       = module.ecs_testbed_app1.ecs_public_ips
# }

# output "ecs_app1_private_ips" {
#   description = "Private IP addresses for app1 instance login"
#   value       = module.ecs_testbed_app1.ecs_private_ips
# }

# # App 2
# output "ecs_app2_public_ips" {
#   description = "Public IP addresses for app2 instance login"
#   value       = module.ecs_testbed_app2.ecs_public_ips
# }

# output "ecs_app2_private_ips" {
#   description = "Private IP addresses for app2 instance login"
#   value       = module.ecs_testbed_app2.ecs_private_ips
# }

# # ECS Password info
# output "ecs_logon_password" {
#   description = "ECS logon password for test instances"
#   value       = random_password.ecs_password.result
#   sensitive   = true
# }
