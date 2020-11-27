#
# Configure Cross-Account SLS Audit Role (root_actiontrail)
#
# Author: Jeremy Pedersen
# Created 2020-01-27
# Updated: 2020-11-27

###
# Policy configuration
###
resource "alicloud_ram_policy" "monitor-access-policy" {
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
  description = "Policy to allow root account access to monitor services"
  force       = true
}

resource "alicloud_ram_policy" "service-dispatch-policy" {
  name        = "AliyunLogAuditServiceDispatchPolicy"
  document    = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": [
          "log:*"
        ],
        "Resource": [
          "acs:log:*:*:project/slsaudit-*"
        ],
        "Effect": "Allow"
      }
    ]
  }
  EOF
  description = "Policy to allow root account to dispatch services"
  force       = true
}

###
# Role Configuration
###

# Create audit service role
# Note: the fancy-looking code in locals {} takes a list of account ID numbers from var.account_ids
# and converts it into a single string object separated with commas and newlines, which can then
# be inserted inline into the policy document. This allows us to generate policy documents for
# an arbitrary number of subaccounts.
locals {
  sub_ids = chomp(join("", formatlist("\"%s@log.aliyuncs.com\",\n", var.account_ids)))
}

resource "alicloud_ram_role" "sls-audit-service" {
  name        = "sls-audit-service-dispatch"
  document    = <<EOF
  {
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            ${local.sub_ids}
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

# Attach policy to role
resource "alicloud_ram_role_policy_attachment" "dispatch-policy-attach" {
  policy_name = alicloud_ram_policy.service-dispatch-policy.name
  policy_type = alicloud_ram_policy.service-dispatch-policy.type
  role_name   = alicloud_ram_role.sls-audit-service.name
}

# Create service monitor role
resource "alicloud_ram_role" "sls-monitor-service" {
  name        = "sls-audit-service-monitor"
  document    = <<EOF
  {
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "log.aliyuncs.com"
          ]
        }
      }
    ],
    "Version": "1"
  }
    EOF
  description = "Role to enable SLS cross-account monitoring"
  force       = true
}

# Attach policy to role
resource "alicloud_ram_role_policy_attachment" "monitor-policy-attach" {
  policy_name = alicloud_ram_policy.monitor-access-policy.name
  policy_type = alicloud_ram_policy.monitor-access-policy.type
  role_name   = alicloud_ram_role.sls-monitor-service.name
}

# Additionaly, attach the system policy ReadOnlyAccess
resource "alicloud_ram_role_policy_attachment" "readonly-policy-attach" {
  policy_name = "ReadOnlyAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.sls-monitor-service.name
}
