# Module - Azure PostgreSQL Flexible Server

[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

This module standardizes the creation of Azure PostgreSQL Flexible Server instances.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------|-----------------|
| v1.0.0         | v1.6.4            | 3.82.0          |
| v2.0.0         | v1.14.0           | 4.54.0          |
| v5.8.0         | >= 1.16.5         | >= 5.8.0        |

## Specifying a version

To avoid using the latest module version automatically, specify the `?ref=***` parameter in the source URL, where `***` is a git tag in the module repository.

Example:
```hcl
source = "git::https://github.com/danilomnds/terraform-azurerm-postgresql?ref=v5.8.0"
```

## Use case

### Private PostgreSQL Server

Configure the provider in the consuming root module. Supply the administrator password from a secret store or sensitive environment input, never from source control.

```hcl
provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

variable "administrator_password" {
  type      = string
  sensitive = true
}

module "postgresql" {
  source                 = "git::https://github.com/danilomnds/terraform-azurerm-postgresql?ref=v5.8.0"
  name                   = "pg-flex-example-dev"
  location               = "westeurope"
  resource_group_name    = "rg-example-dev"
  postgresql_version     = "16"
  sku_name               = "GP_Standard_D2s_v3"
  administrator_login    = "psqladmin"
  administrator_password = var.administrator_password
  delegated_subnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/postgresql"
  private_dns_zone_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example-network/providers/Microsoft.Network/privateDnsZones/example.postgres.database.azure.com"
  zone                   = "1"
  backup_retention_days = 7
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  auto_grow_enabled = false
  storage_mb        = 32768
  storage_tier      = "P4"
  storage_type      = "Premium_LRS"

  timeouts = {
    create = "90m"
    update = "90m"
  }

  tags = {
    environment = "development"
    owner       = "platform-team"
  }
  
  databases = [
    {
      name      = "db01"
      charset   = "UTF8"
      collation = "en_US.utf8"
    },
    {
      name      = "db02"
      charset   = "UTF8"
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
  value = module.postgresql.name
}

output "postgresql_id" {
  value = module.postgresql.id
}

output "postgresql_fqdn" {
  value = module.postgresql.fqdn
}

output "databases" {
  value = module.postgresql.dbs
}

output "configurations" {
  value = module.postgresql.configs
}
```

The delegated subnet must be dedicated to PostgreSQL Flexible Server and delegated to `Microsoft.DBforPostgreSQL/flexibleServers`. The private DNS zone must end in `.postgres.database.azure.com` and be linked to the appropriate virtual network. Create these network resources before using the module. Public network access defaults to `false`.

### Premium SSD v2

For a compatible region, SKU and PostgreSQL version, configure these inputs in the module call:

```hcl
storage_type       = "PremiumV2_LRS"
storage_mb         = 32768
storage_iops       = 12000
storage_throughput = 500
auto_grow_enabled  = false
```

Do not set `storage_tier` or enable auto-grow with Premium SSD v2. `storage_iops` and `storage_throughput` are required only with `PremiumV2_LRS`. PostgreSQL 11-13 are not supported with this storage type; regional and service limitations also apply.

### Optional Cluster

```hcl
postgresql_version = "17"
create_mode        = "Default"
cluster = {
  size                  = 1
  default_database_name = "application"
}
```

Cluster support requires PostgreSQL 17 or later and `Default` creation mode. The provider accepts sizes 1-32, but the service currently supports up to 20 nodes according to the provider documentation. Nodes can be added but not removed, and major PostgreSQL version upgrades are not supported for clusters.

### Credentials and Access

This module does not generate administrator passwords. For a new server using password authentication, supply either `administrator_password` or `administrator_password_wo`, not both. Increment `administrator_password_wo_version` when rotating a write-only password. Password inputs are sensitive; conventional password values are stored in Terraform state, so protect the backend and saved plans.

For Entra-only authentication, set `administrator_login = null`, disable password authentication, enable `active_directory_auth_enabled`, and supply `tenant_id`. Entra administrator provisioning is outside this module.

`azure_ad_groups` assigns the Azure Reader role on the server when `reader_postgresql = true`. These are control-plane permissions, not PostgreSQL database logins or SQL grants. The deploying identity needs permission to create role assignments when this list is populated.

Default tags and the lifecycle ignores for `create_date`, `zone`, and the HA standby zone are preserved. Review changes that force replacement carefully, especially server name, resource group, region, storage type, or reductions in storage size.

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | PostgreSQL Flexible Server name | `string` | n/a | Yes |
| resource_group_name | Name of the resource group in which the PostgreSQL Flexible Server exists | `string` | n/a | Yes |
| location | Azure region | `string` | n/a | Yes |
| administrator_login | Administrator login for the PostgreSQL Flexible Server | `string` | `psqladmin` | No |
| administrator_password | Sensitive administrator password supplied by the caller | `string` | `null` | Conditional |
| administrator_password_wo | Sensitive write-only alternative administrator password | `string` | `null` | Conditional |
| administrator_password_wo_version | Integer to trigger update for administrator_password_wo | `number` | `null` | No |
| authentication | Authentication configuration block (see Object variables section) | `object` | `null` | No |
| backup_retention_days | Backup retention period in days | `number` | `7` | No |
| cluster | Cluster configuration for PostgreSQL 17 or later | `object` | `null` | No |
| customer_managed_key | Customer-managed key configuration block (see Object variables section) | `object` | `null` | No |
| geo_redundant_backup_enabled | Enable geo-redundant backup | `bool` | `false` | No |
| create_mode | Creation mode: `Default`, `GeoRestore`, `PointInTimeRestore`, `Replica`, `ReviveDropped`, or `Update` | `string` | `null` | No |
| delegated_subnet_id | Resource ID of the dedicated delegated subnet | `string` | `null` | No |
| private_dns_zone_id | Private DNS zone ID; required for delegated networking | `string` | `null` | Conditional |
| public_network_access_enabled | Allow public network access | `bool` | `false` | No |
| high_availability | High availability configuration block (see Object variables section) | `object` | `null` | No |
| identity | Managed identity configuration block (see Object variables section) | `object` | `null` | No |
| maintenance_window | Maintenance window configuration block (see Object variables section) | `object` | `null` | No |
| point_in_time_restore_time_in_utc | UTC restore timestamp | `string` | `null` | No |
| replication_role | Only `None` is supported, when promoting an existing replica | `string` | `null` | No |
| sku_name | SKU name for the PostgreSQL Flexible Server | `string` | `null` | No |
| source_server_id | Source server ID for restore or replication | `string` | `null` | Conditional |
| auto_grow_enabled | Enable storage auto-grow | `bool` | `false` | No |
| storage_mb | Maximum storage in MB; Azure defaults to 32768 on initial deployment | `number` | `null` | No |
| storage_tier | Storage performance tier for Premium LRS | `string` | `null` | No |
| storage_type | `Premium_LRS` or `PremiumV2_LRS` | `string` | `Premium_LRS` | No |
| storage_iops | Premium SSD v2 IOPS, from 3000 to 80000 | `number` | `null` | Conditional |
| storage_throughput | Premium SSD v2 throughput in MB/s, from 125 to 1200 | `number` | `null` | Conditional |
| postgresql_version | PostgreSQL version 11-18; required for Default creation mode | `string` | `null` | Conditional |
| zone | Availability zone where the server should be located | `string` | `null` | No |
| tags | Tags for the resource | `map(string)` | `{}` | No |
| timeouts | Server operation timeouts (see Object variables section) | `object` | `null` | No |
| azure_ad_groups | Entra principal Object IDs receiving the Azure Reader role on the server | `list(string)` | `[]` | No |
| databases | Database objects with optional charset, collation, and timeouts | `list(object)` | `null` | No |
| reader_postgresql | Grant reader access to the server | `bool` | `true` | No |
| postgresql_configuration | PostgreSQL server configuration objects with optional timeouts | `list(object)` | `null` | No |

## Object variables for blocks

| Block | Parameter | Description | Type | Default | Required |
|-------|-----------|-------------|------|---------|:--------:|
| cluster | size | Number of cluster nodes | `number` | n/a | Yes |
| cluster | default_database_name | Default database name | `string` | `null` | No |
| authentication | active_directory_auth_enabled | Enable Azure Active Directory authentication | `bool` | `false` | No |
| authentication | password_auth_enabled | Enable password authentication | `bool` | `true` | No |
| authentication | tenant_id | Azure AD tenant ID for authentication | `string` | `null` | No |
| customer_managed_key | key_vault_key_id | Versioned or versionless Key Vault key ID for encryption | `string` | n/a | Yes |
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
| timeouts | create | Server creation timeout | `string` | `1h` | No |
| timeouts | read | Server read timeout | `string` | `5m` | No |
| timeouts | update | Server update timeout | `string` | `1h` | No |
| timeouts | delete | Server deletion timeout | `string` | `1h` | No |
| databases | charset | PostgreSQL character set | `string` | `UTF8` | No |
| databases | collation | PostgreSQL collation | `string` | `en_US.utf8` | No |
| databases.timeouts | create | Database creation timeout | `string` | `30m` | No |
| databases.timeouts | read | Database read timeout | `string` | `5m` | No |
| databases.timeouts | delete | Database deletion timeout | `string` | `30m` | No |
| postgresql_configuration | name | PostgreSQL configuration parameter name | `string` | n/a | Yes |
| postgresql_configuration | value | PostgreSQL configuration parameter value | `string` | n/a | Yes |
| postgresql_configuration.timeouts | create | Configuration creation timeout | `string` | `30m` | No |
| postgresql_configuration.timeouts | read | Configuration read timeout | `string` | `5m` | No |
| postgresql_configuration.timeouts | update | Configuration update timeout | `string` | `30m` | No |
| postgresql_configuration.timeouts | delete | Configuration deletion timeout | `string` | `30m` | No |

Nested blocks are optional as a whole. Required attributes apply only when their block is supplied. Omitted timeout attributes use provider defaults; specify durations such as `"90m"`. Authentication and maintenance fields with null values use provider defaults.

## Output variables

| Name | Description |
|------|-------------|
| name | PostgreSQL Flexible Server name |
| id | PostgreSQL Flexible Server resource ID |
| fqdn | PostgreSQL Flexible Server fully qualified domain name |
| identity | Managed identity attributes, including principal and tenant IDs |
| dbs | PostgreSQL Flexible Server database resource IDs |
| configs | PostgreSQL Flexible Server configuration resource IDs |

## Documentation

PostgreSQL Flexible Server:  
https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/postgresql_flexible_server

PostgreSQL Flexible Database:  
https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/postgresql_flexible_server_database

PostgreSQL Flexible Server Configuration:  
https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/postgresql_flexible_server_configuration

## Maintainer

For issues or feature requests, open an issue in the public GitHub repository.

## Validation

Run `terraform fmt -check -recursive`, `terraform init -backend=false`, `terraform validate`, and `terraform test`. The tests use a mocked AzureRM provider and plan-only runs; they do not connect to Azure or create infrastructure.

## Release Notes

### [v5.8.0] - 2026-10-05

#### Added
- PostgreSQL 17+ cluster configuration and Premium SSD v2 storage inputs.
- Server, database, and server configuration operation timeouts.
- Server `fqdn` and managed `identity` outputs.
- Mocked Terraform tests for database defaults, Premium SSD v2 with cluster configuration, write-only credentials, and disabled Reader assignments.

#### Changed
- Raised Terraform CLI to `>= 1.16.5` and AzureRM to `>= 5.8.0`.
- Marked administrator passwords as sensitive and delegated password provisioning to the consuming root module.
- Corrected `administrator_password_wo_version` to `number`, availability zones to `string`, and CMK `key_vault_key_id` to a required field when the block is provided.
- Made SKU, storage size, and PostgreSQL version optional at module level where provider context allows it.
- Added default database charset `UTF8` and collation `en_US.utf8`.

#### Fixed
- Removed MySQL and Application Insights copy-paste references from PostgreSQL documentation and input descriptions.
- Updated examples to supply administrator credentials explicitly and use a General Purpose SKU for high availability.

#### Removed
- Removed internal `random_password.password` generation and its dependency; no module input variables were removed.

#### Migration
- For existing servers, supply the current administrator password from a secure source before upgrading; do not generate a replacement unless rotation is intended.
- For new password-authenticated servers, explicitly supply one of the sensitive administrator password inputs.
- Pass write-only password versions as numbers and availability zones as strings. Supply `customer_managed_key.key_vault_key_id` when using CMK.
- Existing resource addresses for the server, databases, configurations, and Reader assignments are preserved. Review the plan and protect your state backup before applying changes.