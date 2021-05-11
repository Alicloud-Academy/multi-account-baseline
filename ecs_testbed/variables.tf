#
# Variables used in main.tf (ecs_testbed)
#
variable "env_name" {
  description = "Identifier to use in ECS, Security Group, and SSH key names to identify the environment"
}

variable "root_uid" {
  description = "UID of root account"
}

variable "password" {
  description = "Password for ECS instance login"
}

variable "abc_image_id" {
  description = "Disk image to use when spinning up ECS instances"
  default     = "ubuntu_20_04_x64_20G_alibase_20210420.vhd"
}
