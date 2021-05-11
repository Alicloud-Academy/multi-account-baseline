# Audit Access Policy for Alibaba Cloud Multi-Account Baseline
#
# Author: Jeremy Pedersen
# Creation Date: 2019-12-30
# Last Updated: 2021-05-11
#

# Fetch RAM login alias
data "alicloud_ram_account_aliases" "ram_alias" {}

# Create audit account, with console login access
resource "alicloud_ram_user" "ram-audit" {
  name         = var.account_name
  display_name = var.account_display_name
  force        = true
}

# Login password for RAM user
resource "alicloud_ram_login_profile" "ram-audit-profile" {
  user_name = alicloud_ram_user.ram-audit.name
  password  = var.password
}

# Custom policy to deny access to BSS (billing)
# and allow the RAM account to assume an "audit" 
# role under other accounts
resource "alicloud_ram_policy" "ram-audit-policy" {
  policy_name     = "audit"
  policy_document = <<EOF
  {
    "Statement": [
      {
        "Action": "bss:*",
        "Resource": "*",
        "Effect": "Deny"
      },
      {
        "Action": "sts:AssumeRole",
        "Resource": "acs:ram::*:role/${var.role_name}",
        "Effect": "Allow"
      }
    ],
    "Version": "1"
  }
  EOF
  description     = "Audit and Security Check Access Policy"
  force           = true
}

# Attach the policy to the RAM user
resource "alicloud_ram_user_policy_attachment" "audit-attach" {
  policy_name = alicloud_ram_policy.ram-audit-policy.name
  policy_type = alicloud_ram_policy.ram-audit-policy.type
  user_name   = alicloud_ram_user.ram-audit.name
}

# Attach additional ReadOnlyAccess system policy to the user
resource "alicloud_ram_user_policy_attachment" "readonly-attach" {
  policy_name = "ReadOnlyAccess"
  policy_type = "System"
  user_name   = alicloud_ram_user.ram-audit.name
}
