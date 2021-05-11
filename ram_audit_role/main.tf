# Audit role for app and shared svc accounts
#
# Author: Jeremy Pedersen
# Creation Date: 2020-01-26
# Last Updated: 2021-05-11
#

###
# RAM role and policy configuration for audit access
# - Allows read only on all recources EXCEPT billing
###
resource "alicloud_ram_role" "audit-role" {
  name        = "audit-role"
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
  description = "Audit Access Role"
  force       = true
}

# Custom policy to explicity deny access to BSS (billing) info
resource "alicloud_ram_policy" "ram-audit-policy" {
  policy_name     = "audit-policy"
  policy_document = <<EOF
  {
    "Version": "1",
    "Statement": [
          {
              "Action": "bss:*",
              "Resource": "*",
              "Effect": "Deny"
          }
    ]
  }
  EOF
  description     = "Audit Access Policy"
  force           = true
}

# Attach custom policy
resource "alicloud_ram_role_policy_attachment" "audit-attach" {
  policy_name = alicloud_ram_policy.ram-audit-policy.name
  policy_type = alicloud_ram_policy.ram-audit-policy.type
  role_name   = alicloud_ram_role.audit-role.name
}

# Attach ReadOnlyAccess system policy
resource "alicloud_ram_role_policy_attachment" "readonly-attach" {
  policy_name = "ReadOnlyAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.audit-role.name
}

