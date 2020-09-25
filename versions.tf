terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
