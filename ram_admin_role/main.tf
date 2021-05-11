# Billing role for app and shared svc accounts
#
# Author: Jeremy Pedersen
# Creation Date: 2020-01-26
# Last Updated: 2021-05-11
#
resource "alicloud_ram_role" "admin-role" {
  name        = "admin-role"
  document    = <<EOF
  {
      "Version": "1",
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Effect": "Allow",
              "Principal": {
                "RAM": [
                  "acs:ram::${var.root_uid}:root"
                ]
              }
          }
      ]
  }
  EOF
  description = "Admin Access Role"
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "admin-attach" {
  policy_name = "AdministratorAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.admin-role.name
}
