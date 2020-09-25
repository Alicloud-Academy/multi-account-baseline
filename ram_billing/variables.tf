# Variables used in main.tf
variable "password" {
  description = "Password for administrator RAM user"
}

variable "account_name" {
  description = "Account name for new RAM account (will be used for login)"
  default     = "billing"
}

variable "account_display_name" {
  description = "The RAM account's display name (will be shown in lists of RAM users, as well as in the upper right hand corner of the console after login)"
  default     = "billing"
}

variable "role_name" {
  description = "Role name for audit role, defaults to billing-role"
  default     = "billing-role"
}
