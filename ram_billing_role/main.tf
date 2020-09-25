# Billing role for app and shared svc accounts
#
# Author: Jeremy Pedersen
# Creation Date: 2020-01-26
# Last Updated: 2020-09-24
#

resource "alicloud_ram_role" "billing-role" {
  name        = "billing-role"
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
  description = "Billing Access Role"
  force       = true
}

resource "alicloud_ram_policy" "ram-billing-policy" {
  name        = "billing-policy"
  document    = <<EOF
  {
    "Version": "1",
    "Statement": [
        {
            "Action": "bss:*",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
  }
  EOF
  description = "Billing Access Policy"
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "billing-attach" {
  policy_name = alicloud_ram_policy.ram-billing-policy.name
  policy_type = alicloud_ram_policy.ram-billing-policy.type
  role_name   = alicloud_ram_role.billing-role.name
}
