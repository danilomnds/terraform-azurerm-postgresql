# Module - Azure PostgreSQL Flexible Server
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the creation of PostgreSQL Flexible Server.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.6.4            | 3.82.0          |

## Specifying a version

To avoid that your code get the latest module version, you can define the `?ref=***` in the URL to point to a specific version.
Note: The `?ref=***` refers a tag on the git module repo.

## Use case
```hcl
module "postgresql-flex-<system>-<env>" {
  source              = "git::https://github.com/danilomnds/terraform-azurerm-postgresql?ref=v1.0.0"
  name                = "postgresql-flex-<system>-<env>"
  location            = <location>
  resource_group_name = <resource group name>
  postgresql_version       = <version>
  sku_name            = <virtual machine shape>
  delegated_subnet_id = "subnet id"
  private_dns_zone_id = "private dns zone id"
  zone                = <1|2|3>
  backup_retention_days = <default 7>
  high_availability = { 
    mode = <SameZone|ZoneRedundant>
    standby_availability_zone = <ex: 2>
  }  
  auto_grow_enabled = false
  storage_mb = <32768>
  tags = {
    key1 = value1
    key2 = value2
  }
  databases = [
    {
     name = "db01"
     charset = "utf8"
     collation = "en_US.utf8"
    },
    {
     name = "db02"
     charset = "utf8"
     collation = "en_US.utf8"
    }
  ]
  postgresql_configuration = [
    { 
      name = parameter1
      value = value1
    },
    { 
      name = parameter2
      value = value2
    },
  ]
  azure_ad_groups = ["group 1 that will have reader access on postgresql", "group 2"]
}
output "postgresql-name" {
  value = module.postgresql-flex-<system>-<env>.name
}
output "postgresql-id" {
  value = module.postgresql-flex-<system>-<env>.id
}
output "dbs" {
  value = module.postgresql-flex-<system>-<env>.dbs
}
output "configs" {
  value = module.postgresql-flex-<system>-<env>.configs
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | postgresql flex server name | `string` | n/a | `Yes` |
| resource_group_name | the name of the resource group in which the MySQL Flexible Server exists | `string` | n/a | `Yes` |
| location | azure region | `string` | n/a | `Yes` |
| administrator_login | the administrator login for the postgresql flexible server | `string` | `psqladmin` | No |
| administrator_password | the password associated with the administrator_login for the postgresql flexible server | `string` | n/a | No |
| authentication | a block as defined below | `object({})` | n/a | No |
| backup_retention_days | the backup retention days for the postgresql flexible server | `number` | `7` | No |
| customer_managed_key | a block as defined below | `object({})` | n/a | No |
| geo_redundant_backup_enabled | should geo redundant backup enabled?  | `bool` | `false` | No |
| create_mode | the creation mode which can be used to restore or replicate existing servers | `string` | n/a | No |
| delegated_subnet_id | the id of the virtual network subnet to create the postgresql flexible server | `string` | n/a | No |
| private_dns_zone_id | the id of the private dns zone to create the postgresql flexible server | `string` | n/a | No |
| high_availability | a block as defined below | `object({})` | n/a | No |
| identity | a block as defined below | `object({})` | n/a | No |
| maintenance_window | a block as defined below | `object({})` | n/a | No |
| point_in_time_restore_time_in_utc | the point in time to restore from creation_source_server_id when create_mode is pointintimerestore | `string` | n/a | No |
| replication_role | the replication role. possible value is none | `string` | n/a | No |
| sku_name | the sku name for the postgresql flexible server | `string` | n/a | `Yes` |
| source_server_id | the resource id of the source postgresql flexible server to be restored | `string` | n/a | No |
| auto_grow_enabled | is the storage auto grow for postgresql flexible server enabled? | `bool` | `false` | No |
| storage_mb | the max storage allowed for the postgresql flexible server | `number` | n/a | `Yes` |
| postgresql_version | the version of the postgresql flexible server to use | `string` | n/a | `Yes` |
| zone | specifies the availability zone in which this postgresql flexible server should be located | `string` | n/a | No |
| tags | tags for the resource | `map(string)` | `{}` | No |
| azure_ad_groups | list of azure AD groups that will be granted the Application Insights Component Contributor role  | `list` | `[]` | No |
| databases | a list object variable defined below | `list(object({}))` | n/a | No |
| reader_postgresql | should reader access granted? | `bool` | `True` | No |
| postgresql_configuration | a list object variable defined below | `list(object({}))` | n/a | No |


# Object variables for blocks

| Variable Name (Block) | Parameter | Description | Type | Default | Required |
|-----------------------|-----------|-------------|------|---------|:--------:|
| authentication | active_directory_auth_enabled | whether or not active directory authentication is allowed to access the postgresql flexible server  | `bool` | `false` | No |
| authentication | password_auth_enabled | whether or not password authentication is allowed to access the postgresql flexible server | `bool` | `true` | No |
| authentication | tenant_id | the tenant id of the azure active directory which is used by the active directory authentication | `string` | `null` | No |
| customer_managed_key | key_vault_key_id | the id of the key vault key | `string` | `null` | No |
| customer_managed_key | primary_user_assigned_identity_id | specifies the primary user managed identity id for a customer managed key | `string` | `null` | No |
| customer_managed_key | geo_backup_key_vault_key_id | the id of the geo backup key vault key | `string` | `null` | No |
| customer_managed_key | geo_backup_user_assigned_identity_id | the geo backup user managed identity id for a customer managed key | `string` | `null` | No |
| identity | type | specifies the type of managed service identity that should be configured on this event hub namespace | `string` | `null` | No |
| identity | identity_ids | specifies a list of user assigned managed identity ids to be assigned to this eventhub namespace | `list(string)` | `null` | No |
| high_availability | mode | the high availability mode for the postgresql flexible server. possibles values are samezone and zoneredundant | `string` | `null` | `Yes` |
| high_availability | standby_availability_zone | specifies the availability zone in which the standby flexible server should be located | `list(string)` | `null` | No |
| high_availability | mode | the high availability mode for the postgresql flexible server. possibles values are samezone and zoneredundant | `string` | `null` | `Yes` |
| high_availability | standby_availability_zone | specifies the availability zone in which the standby flexible server should be located | `list(string)` | `null` | No |
| maintenance_window | day_of_week | the day of week for maintenance window | `number` | `0` | No |
| maintenance_window | start_hour | the start hour for maintenance window | `number` | `0` | No |
| maintenance_window | start_minute | the start minute for maintenance window | `number` | `0` | No |
| databases | name | database name | `string` | n/a | `Yes` |
| databases | charset | database charset | `string` | n/a | `Yes` |
| databases | collation | database collation | `string` | n/a | `Yes` |
| postgresql_configuration | name | specifies the name of the postgresql flexible server configuration, which needs to be a valid postgresql configuration name | `string` | n/a | `Yes` |
| postgresql_configuration | value | specifies the value of the postgresql flexible server configuration. see the postgresql documentation for valid values | `string` | n/a | `Yes` |

  ## Output variables

| Name | Description |
|------|-------------|
| name | flexible server name|
| id | flexible server id |
| dbs | flexible database id |
| configs | flexible configuration id| 

## Documentation
PostgreSQL Flexible Server: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)

PostgreSQL Flexible Database: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_database) 

PostgreSQL Flexible Configuration: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration)