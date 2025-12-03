# Module - Azure PostgreSQL Flexible Server

[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

This module standardizes the creation of Azure PostgreSQL Flexible Server instances.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------|-----------------|
| v1.0.0         | v1.6.4            | 3.82.0          |
| v2.0.0         | v1.14.0           | 4.54.0          |

## Specifying a version

To avoid using the latest module version automatically, specify the `?ref=***` parameter in the source URL, where `***` is a git tag in the module repository.

Example:
```hcl
source = "git::https://github.com/danilomnds/terraform-azurerm-postgresql?ref=v2.0.0"
```

## Use case

```hcl
module "postgresql_flex_system_fqa" {
  source              = "git::https://github.com/danilomnds/terraform-azurerm-postgresql?ref=v2.0.0"
  name                = "postgresql-flex-system-fqa"
  location            = "brazilsouth"
  resource_group_name = "rg-infra-fqa"
  postgresql_version  = "14"
  sku_name            = "B_Standard_B1ms"
  delegated_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-infra/providers/Microsoft.Network/virtualNetworks/vnet-infra/subnets/postgresql"
  private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-infra/providers/Microsoft.Network/privateDnsZones/postgres.database.azure.com"
  zone                = "1"
  backup_retention_days = 7
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  auto_grow_enabled = false
  storage_mb        = 32768
  storage_tier      = "P4"
  
  tags = {
    environment = "fqa"
    owner       = "platform-team"
  }
  
  databases = [
    {
      name      = "db01"
      charset   = "utf8"
      collation = "en_US.utf8"
    },
    {
      name      = "db02"
      charset   = "utf8"
      collation = "en_US.utf8"
    }
  ]
  
  postgresql_configuration = [
    {
      name  = "max_connections"
      value = "100"
    },
    {
      name  = "shared_buffers"
      value = "262144"
    }
  ]
  
  azure_ad_groups = [
    "00000000-0000-0000-0000-000000000001",  # Team A object ID
    "00000000-0000-0000-0000-000000000002"   # Team B object ID
  ]
}

output "postgresql_name" {
  value = module.postgresql_flex_system_fqa.name
}

output "postgresql_id" {
  value = module.postgresql_flex_system_fqa.id
}

output "databases" {
  value = module.postgresql_flex_system_fqa.dbs
}

output "configurations" {
  value = module.postgresql_flex_system_fqa.configs
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | PostgreSQL Flexible Server name | `string` | n/a | Yes |
| resource_group_name | Name of the resource group in which the PostgreSQL Flexible Server exists | `string` | n/a | Yes |
| location | Azure region | `string` | n/a | Yes |
| administrator_login | Administrator login for the PostgreSQL Flexible Server | `string` | `psqladmin` | No |
| administrator_password | Password associated with the administrator_login | `string` | n/a | No |
| administrator_password_wo | Alternate password field (write-only) | `string` | n/a | No |
| administrator_password_wo_version | Integer to trigger update for administrator_password_wo | `number` | n/a | No |
| authentication | Authentication configuration block (see Object variables section) | `object({})` | n/a | No |
| backup_retention_days | Backup retention period in days | `number` | `7` | No |
| customer_managed_key | Customer-managed key configuration block (see Object variables section) | `object({})` | n/a | No |
| geo_redundant_backup_enabled | Enable geo-redundant backup | `bool` | `false` | No |
| create_mode | Creation mode for restore or replication (`Default`, `PointInTimeRestore`, `Replica`) | `string` | n/a | No |
| delegated_subnet_id | Resource ID of the virtual network subnet for the PostgreSQL Flexible Server | `string` | n/a | No |
| private_dns_zone_id | Resource ID of the private DNS zone for the PostgreSQL Flexible Server | `string` | n/a | No |
| public_network_access_enabled | Allow public network access | `bool` | `false` | No |
| high_availability | High availability configuration block (see Object variables section) | `object({})` | n/a | No |
| identity | Managed identity configuration block (see Object variables section) | `object({})` | n/a | No |
| maintenance_window | Maintenance window configuration block (see Object variables section) | `object({})` | n/a | No |
| point_in_time_restore_time_in_utc | Point in time (UTC) to restore from when create_mode is PointInTimeRestore | `string` | n/a | No |
| replication_role | Replication role (`None` or `Replica`) | `string` | n/a | No |
| sku_name | SKU name for the PostgreSQL Flexible Server | `string` | n/a | Yes |
| source_server_id | Resource ID of the source PostgreSQL Flexible Server for restore operations | `string` | n/a | No |
| auto_grow_enabled | Enable storage auto-grow | `bool` | `false` | No |
| storage_mb | Maximum storage allowed (in MB) | `number` | n/a | Yes |
| storage_tier | Storage performance tier for IOPS (e.g., `P4`, `P6`, `P10`) | `string` | n/a | No |
| postgresql_version | PostgreSQL version (e.g., `13`, `14`, `15`) | `string` | n/a | Yes |
| zone | Availability zone where the server should be located (e.g., `1`, `2`, `3`) | `string` | n/a | No |
| tags | Tags for the resource | `map(string)` | `{}` | No |
| azure_ad_groups | List of Azure AD principal object IDs to grant Application Insights Component Contributor role | `list(string)` | `[]` | No |
| databases | List of database configuration objects (see Object variables section) | `list(object({}))` | n/a | No |
| reader_postgresql | Grant reader access to the server | `bool` | `true` | No |
| postgresql_configuration | List of PostgreSQL server configuration objects (see Object variables section) | `list(object({}))` | n/a | No |

## Object variables for blocks

| Block | Parameter | Description | Type | Default | Required |
|-------|-----------|-------------|------|---------|:--------:|
| authentication | active_directory_auth_enabled | Enable Azure Active Directory authentication | `bool` | `false` | No |
| authentication | password_auth_enabled | Enable password authentication | `bool` | `true` | No |
| authentication | tenant_id | Azure AD tenant ID for authentication | `string` | `null` | No |
| customer_managed_key | key_vault_key_id | Key Vault key ID for encryption | `string` | `null` | No |
| customer_managed_key | primary_user_assigned_identity_id | User-assigned managed identity ID for primary encryption | `string` | `null` | No |
| customer_managed_key | geo_backup_key_vault_key_id | Key Vault key ID for geo-backup encryption | `string` | `null` | No |
| customer_managed_key | geo_backup_user_assigned_identity_id | User-assigned managed identity ID for geo-backup encryption | `string` | `null` | No |
| identity | type | Managed identity type (`SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`) | `string` | `null` | No |
| identity | identity_ids | List of user-assigned managed identity resource IDs | `list(string)` | `null` | No |
| high_availability | mode | High availability mode (`SameZone` or `ZoneRedundant`) | `string` | `null` | Yes |
| high_availability | standby_availability_zone | Availability zone for the standby server (e.g., `2`, `3`) | `string` | `null` | No |
| maintenance_window | day_of_week | Day of week for maintenance (0=Sunday, 6=Saturday) | `number` | `0` | No |
| maintenance_window | start_hour | Start hour for maintenance window (0–23) | `number` | `0` | No |
| maintenance_window | start_minute | Start minute for maintenance window (0–59) | `number` | `0` | No |
| databases | name | Database name | `string` | n/a | Yes |
| databases | charset | Character set (e.g., `utf8`, `utf8mb4`) | `string` | n/a | Yes |
| databases | collation | Collation (e.g., `en_US.utf8`) | `string` | n/a | Yes |
| postgresql_configuration | name | PostgreSQL configuration parameter name | `string` | n/a | Yes |
| postgresql_configuration | value | PostgreSQL configuration parameter value | `string` | n/a | Yes |

## Output variables

| Name | Description |
|------|-------------|
| name | PostgreSQL Flexible Server name |
| id | PostgreSQL Flexible Server resource ID |
| dbs | PostgreSQL Flexible Server database resource IDs |
| configs | PostgreSQL Flexible Server configuration resource IDs |

## Documentation

PostgreSQL Flexible Server:  
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server

PostgreSQL Flexible Database:  
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_database

PostgreSQL Flexible Server Configuration:  
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration

## Maintainer

CCoE — InfraCloud  
For issues or feature requests, open an issue in this repository.