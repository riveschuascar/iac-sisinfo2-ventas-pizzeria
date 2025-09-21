terraform{
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">= 4.43.0"
        }
    }   
}
provider "azurerm" {
    features {}
    # configurar provider para autenticacion via CLI
    client_id = "<ID> del CLIENTE de AZURE"
    tenant_id = "<ID> del 'tenant' del CLIENTE de AZURE"
    subscription_id = "<ID> de la suscripcion de AZURE"
    client_secret = "<CONTRASENA> del CLIENTE de AZURE"
}

locals {
    rg-region = "Brasil South"
    sql-region = "Central US"
}

# Crear el Grupo de Recursos
resource "azurerm_resource_group" "rg" {
    name     = "rg-sisinfo2-8848488-8055452"
    location = local.rg-region
}

# Crear la Cuenta de Almacenamiento
resource "azurerm_storage_account" "sa" {
    name                     = "sasisinfo88484888055452"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind = "StorageV2"
    allow_nested_items_to_be_public = true
}

# Crear el Contenedor 'ventas'
resource "azurerm_storage_container" "ventas" {
    name                  = "ventas"
    storage_account_id    = azurerm_storage_account.sa.id
    container_access_type = "blob"
}

# Cargar los archivos al contenedor 'ventas'
resource "azurerm_storage_blob" "ventas_csv" {
    name                   = "ventas.csv"
    storage_account_name   = azurerm_storage_account.sa.name
    storage_container_name = azurerm_storage_container.ventas.name
    type                   = "Block"
    source                 = "dataset/ventas.csv"
}

resource "azurerm_storage_blob" "ventas_xlsx" {
    name                   = "ventas.xlsx"
    storage_account_name   = azurerm_storage_account.sa.name
    storage_container_name = azurerm_storage_container.ventas.name
    type                   = "Block"
    source                 = "dataset/ventas.csv"
}

# Crear un servidor de base de datos 'SQL Server'
resource "azurerm_mssql_server" "sqlserver" {
    name                         = "sql-ucb-sisinfo2-8848488-8055452"
    resource_group_name          = azurerm_resource_group.rg.name
    location                     = local.sql-region
    version                      = "12.0"
    administrator_login          = "eladmin"
    administrator_login_password = "@password1"
    public_network_access_enabled = true
}

# Crear la BD en el servidor SQL
resource "azurerm_mssql_database" "supertiendaDB_bronze" {
    name           = "dw-ventas"
    server_id      = azurerm_mssql_server.sqlserver.id
    sku_name       = "GP_S_Gen5"
    collation      = "SQL_Latin1_General_CP1_CI_AS"
    max_size_gb    = 8
    zone_redundant = false
}

# Crear una regla de firewall para permitir el acceso a la base de datos desde cualquier ip
resource "azurerm_mssql_firewall_rule" "allow_all" {
    name                = "allow_all"
    server_id           = azurerm_mssql_server.sqlserver.id
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "255.255.255.255"
}

# Crear el datafactory v2
resource "azurerm_data_factory" "adf" {
    name                = "df-ucb-sisinfo2-8848488-8055452"
    location            = local.sql-region
    resource_group_name = azurerm_resource_group.rg.name
}