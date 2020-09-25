# Variables used in main.tf (system_logs)
variable "root_uid" {
  description = "UID of root account"
}

variable "machine_identity_list" {
  description = "A list of machine 'custom identifiers' to differentiate the logs collected from each subaccount"
}

