# Administrator Access Policy for Alibaba Cloud Multi-Account Baseline
#
# Author: Jeremy Pedersen
# Creation Date: 2019-12-30
# Last Updated: 2021-05-11

# Fetch RAM login alias
data "alicloud_ram_account_aliases" "ram_alias" {}

# Create billing account, with console login access
resource "alicloud_ram_user" "ram-billing" {
  name         = var.account_name
  display_name = var.account_display_name
  force        = true
}

resource "alicloud_ram_login_profile" "ram-billing-profile" {
  user_name = alicloud_ram_user.ram-billing.name
  password  = var.password
}

# Create new billing system access policy
resource "alicloud_ram_policy" "ram-billing-policy" {
  policy_name     = "billing"
  policy_document = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": "bss:*",
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": "sts:AssumeRole",
        "Resource": "acs:ram::*:role/${var.role_name}",
        "Effect": "Allow"
      }
    ]
  }
  EOF
  description     = "Billing Access Policy"
  force           = true
}

# Attach the policy to the RAM user
resource "alicloud_ram_user_policy_attachment" "billing-attach" {
  policy_name = alicloud_ram_policy.ram-billing-policy.name
  policy_type = alicloud_ram_policy.ram-billing-policy.type
  user_name   = alicloud_ram_user.ram-billing.name
}
