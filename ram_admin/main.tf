# Administrator Access Policy for Alibaba Cloud Multi-Account Baseline (ram_admin)
#
# Author: Jeremy Pedersen
# Creation Date: 2019-12-29
# Last Updated: 2020-09-24
#

# Fetch RAM login alias
data "alicloud_ram_account_aliases" "ram_alias" {}

# Create administrator account, with console login access
resource "alicloud_ram_user" "ram-admin" {
  name         = var.account_name
  display_name = var.account_display_name
  force        = true
}

# Set password for user
resource "alicloud_ram_login_profile" "ram-admin-profile" {
  user_name = alicloud_ram_user.ram-admin.name
  password  = var.password
}

# Attach the policy to the RAM user
resource "alicloud_ram_user_policy_attachment" "attach" {
  policy_name = "AdministratorAccess"
  policy_type = "System"
  user_name   = alicloud_ram_user.ram-admin.name
}

