#
# Configure the Log Project(s) and LogStore(s) used to
# collect system and application logs from servers under
# each subaccount
#
# Author: Jeremy Pedersen
# Created 2020-01-27
# Updated: 2020-09-24

# Create Log Service Project
resource "alicloud_log_project" "ecs-logging-project" {
  name        = "ecs-logging-project"
  description = "Log Project for storing system logs from subaccounts"
}

# Create Log Service LogStore
resource "alicloud_log_store" "ecs-log-store" {
  project               = alicloud_log_project.ecs-logging-project.name
  name                  = "ecs-log-store"
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

# Enable indexing on the LogStore
resource "alicloud_log_store_index" "ecs-log-index" {
  project  = alicloud_log_project.ecs-logging-project.name
  logstore = alicloud_log_store.ecs-log-store.name
  full_text {
    case_sensitive = true
    token          = " #$%^*\r\n\t"
  }
}

# Create a Machine Group
resource "alicloud_log_machine_group" "ecs-machine-group" {
  project       = alicloud_log_project.ecs-logging-project.name
  name          = "ecs-machine-group"
  topic         = "system"
  identify_type = "userdefined"
  identify_list = var.machine_identity_list
}

# Create a logtail configuration
resource "alicloud_logtail_config" "ecs-logtail-config" {
  project      = alicloud_log_project.ecs-logging-project.name
  logstore     = alicloud_log_store.ecs-log-store.name
  input_type   = "file"
  log_sample   = "test"
  name         = "ecs-logtail-config"
  output_type  = "LogService"
  input_detail = <<DEFINITION
  {
    "logPath": "/var/log", 
    "filePattern": "*", 
    "logType": "common_reg_log", 
    "topicFormat": "default", 
    "discardUnmatch": false, 
    "enableRawLog": true, 
    "fileEncoding": "utf8", 
    "maxDepth": 10
  }
  DEFINITION
}

# Bind the logtail configuration to the log project/logstore
resource "alicloud_logtail_attachment" "ecs-logtail-attachment" {
  project             = alicloud_log_project.ecs-logging-project.name
  logtail_config_name = alicloud_logtail_config.ecs-logtail-config.name
  machine_group_name  = alicloud_log_machine_group.ecs-machine-group.name
}

