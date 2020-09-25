#
# Output the information required to test the
# environment created in main.tf (ecs_testbed)
#
output "ecs_user_name" {
  description = "Username for (Linux) instance public login"
  value       = "${var.env_name}: root"
}

# Reformat instance IP list for output on the commandline
locals {
  ip_list = "${chomp(join(", ", alicloud_instance.ecs-testbed-instances.*.public_ip))}"
}

# List of instance public IPs
output "ecs_public_ips" {
  description = "Instance public IP addresses"
  value       = "${var.env_name}: ${local.ip_list}"
}

output "ecs_password" {
  description = "Password for ECS instance login"
  value       = "${var.password}"
}
