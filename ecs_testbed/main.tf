#
# ECS Testbed (used to test logging, network configuration) (ecs_testbed)
#
# Author: Jeremy Pedersen
# Created 2019-12-31
# Updated: 2020-09-24

# First, fetch data about Dev, UAT, and Prod VPC groups
data "alicloud_vpcs" "vpc-list" {}

data "alicloud_instance_types" "cores2mem4g" {
  cpu_core_count = 2
  memory_size    = 4
}

###
# Security group configuration
###

# One security group per VPC
resource "alicloud_security_group" "ecs-testbed-sgs" {

  count = length(data.alicloud_vpcs.vpc-list.ids)

  name        = "ecs-testbed-sg-${var.env_name}-${count.index}"
  vpc_id      = data.alicloud_vpcs.vpc-list.ids[count.index]
  description = "Network Test ECS Instance Security Group for ${var.env_name}"
}

# Bind rules to each of the security groups created above
resource "alicloud_security_group_rule" "icmp-in" {

  count = length(alicloud_security_group.ecs-testbed-sgs.*.id)

  type              = "ingress"
  ip_protocol       = "icmp"
  policy            = "accept"
  port_range        = "-1/-1"
  security_group_id = element(alicloud_security_group.ecs-testbed-sgs.*.id, count.index)
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "ssh-in" {

  count = length(alicloud_security_group.ecs-testbed-sgs.*.id)

  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = element(alicloud_security_group.ecs-testbed-sgs.*.id, count.index)
  cidr_ip           = "0.0.0.0/0"
}

# Set up an ECS instance inside each VPC
resource "alicloud_instance" "ecs-testbed-instances" {

  count = length(data.alicloud_vpcs.vpc-list.ids)

  instance_name = "ecs-example-instance-${var.env_name}-${count.index}"

  image_id = var.abc_image_id

  instance_type        = data.alicloud_instance_types.cores2mem4g.instance_types.0.id
  system_disk_category = "cloud_efficiency"
  security_groups      = [element(alicloud_security_group.ecs-testbed-sgs.*.id, count.index)]
  vswitch_id           = element(data.alicloud_vpcs.vpc-list.vpcs.*.vswitch_ids.0, count.index)

  password = var.password

  # Install logging agent (note, have to left-align the bash shellscript to avoid leading whitespace)
  # TODO: Change this so that the region in the URL below changes to match whatever region was 
  # chosen in the root module
  user_data = <<EOF
#!/bin/bash
wget http://logtail-release-cn-hangzhou.oss-cn-hangzhou.aliyuncs.com/linux64/logtail.sh -O logtail.sh; chmod 755 logtail.sh
./logtail.sh install auto
touch /etc/ilogtail/users/${var.root_uid}
echo "${var.env_name}" > /etc/ilogtail/user_defined_id
  EOF

  internet_max_bandwidth_out = 10 # Ensure instance is granted a public IP address
}
