variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "administrator_login" {
  description = "postgresql administrator login"
  type        = string
  default     = "psqladmin"
}

variable "administrator_password" {
  description = "postgresql administrator password"
  type        = string
  default     = null
  sensitive   = true
}

variable "administrator_password_wo" {
  type        = string
  description = "The Password associated with the administrator_login for the PostgreSQL Flexible Server"
  default     = null
  sensitive   = true
}

variable "administrator_password_wo_version" {
  type        = number
  description = "An integer value used to trigger an update for administrator_password_wo"
  default     = null
}

variable "authentication" {
  type = object({
    active_directory_auth_enabled = optional(bool)
    password_auth_enabled         = optional(bool)
    tenant_id                     = optional(string)
  })
  default = null
}

variable "backup_retention_days" {
  description = "Backup retention days for the PostgreSQL Flexible Server (Between 7 and 35 days)."
  type        = number
  default     = 7
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id                     = string
    primary_user_assigned_identity_id    = optional(string)
    geo_backup_key_vault_key_id          = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
  })
  default = null
}

variable "geo_redundant_backup_enabled" {
  type    = bool
  default = false
}

variable "create_mode" {
  type    = string
  default = null
}

variable "delegated_subnet_id" {
  description = "Id of the subnet to create the PostgreSQL Flexible Server. (Should not have any resource deployed in)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone to create the PostgreSQL Flexible Server"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity that should be configured on this resource"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number)
    start_hour   = optional(number)
    start_minute = optional(number)
  })
  default = null
}

variable "point_in_time_restore_time_in_utc" {
  type    = string
  default = null
}

variable "replication_role" {
  type    = string
  default = null
}

variable "sku_name" {
  type    = string
  default = null
}

variable "source_server_id" {
  type    = string
  default = null
}

variable "auto_grow_enabled" {
  type    = bool
  default = false
}

variable "storage_mb" {
  type    = number
  default = null
}

variable "storage_tier" {
  type    = string
  default = null
}

variable "cluster" {
  description = "Cluster configuration for PostgreSQL versions 17 and later."
  type = object({
    size                  = number
    default_database_name = optional(string)
  })
  default = null
}

variable "storage_type" {
  description = "Storage type. Supported values are Premium_LRS and PremiumV2_LRS."
  type        = string
  default     = "Premium_LRS"
}

variable "storage_iops" {
  description = "Maximum storage IOPS. Required with PremiumV2_LRS storage."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Maximum storage throughput in MB/s. Required with PremiumV2_LRS storage."
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to set on every taggable resources. Empty by default."
  type        = map(string)
  default     = {}
}

variable "postgresql_version" {
  description = "Version of postgresql flexible server"
  type        = string
  default     = null
}

variable "zone" {
  description = "Availability zone for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "timeouts" {
  description = "Timeouts for PostgreSQL Flexible Server operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "databases" {
  type = list(object({
    name      = string
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default = null
}

variable "azure_ad_groups" {
  type    = list(string)
  default = []
}

variable "reader_postgresql" {
  description = "Grants reader permissions on PostgreSQL Flexible Server"
  type        = bool
  default     = true
}

variable "postgresql_configuration" {
  type = list(object({
    name  = string
    value = string
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = null
}