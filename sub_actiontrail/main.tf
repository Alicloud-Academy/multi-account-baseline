#
# Configure Cross-Account SLS Audit Role (sub_actiontrail)
#
# Author: Jeremy Pedersen
# Created 2020-01-27
# Updated: 2020-09-24

###
# RAM role configuration to allow cross-account access to ActionTrail 
# info from a specified root account
###

# Create a new RAM policy
resource "alicloud_ram_policy" "audit-service-policy" {
  name        = "AliyunLogAuditServiceMonitorAccess"
  document    = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": "log:*",
        "Resource": [
          "acs:log:*:*:project/slsaudit-*",
          "acs:log:*:*:app/audit"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "rds:ModifySQLCollectorPolicy",
          "vpc:*FlowLog*",
          "drds:*SqlAudit*"
        ],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
  }
  EOF
  description = "Policy to allow root account access to ActionTrail data"
  force       = true
}

# Create an associated role which can be assumed by SLS under the root account
resource "alicloud_ram_role" "sls-audit-service-sub" {
  name        = "sls-audit-service-monitor"
  document    = <<EOF
  {
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "${var.root_uid}@log.aliyuncs.com",
            "log.aliyuncs.com"
          ]
        }
      }
    ],
    "Version": "1"
  }
  EOF
  description = "Role to enable SLS cross-account audit service"
  force       = true
}

# Bind the policy to our new role (also, bind ReadOnlyAccess)
resource "alicloud_ram_role_policy_attachment" "attach-sls-policy" {
  policy_name = alicloud_ram_policy.audit-service-policy.name
  policy_type = alicloud_ram_policy.audit-service-policy.type
  role_name   = alicloud_ram_role.sls-audit-service-sub.name
}

resource "alicloud_ram_role_policy_attachment" "attach-readonly-policy" {
  policy_name = "ReadOnlyAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.sls-audit-service-sub.name
}
