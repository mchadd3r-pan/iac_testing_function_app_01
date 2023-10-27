provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "resourceGroupName"
  location = "westus2"
}

resource "azurerm_storage_account" "example" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}  

resource "azurerm_app_service_plan" "example" {
  name                = "appserviceplanname"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "example" {
  name                       = "functionappname"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.access_key

  site_config {
    http2_enabled = false 
    ftps_state    = "FtpsOnly" 
    min_tls_version = "1.0"

    cors {
      allowed_origins = ["*"] 
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "FUNCTIONS_WORKER_RUNTIME" = "python3.6"
    "FUNCTIONS_EXTENSION_VERSION" = "~2"
    "AzureWebJobsStorage" = azurerm_storage_account.example.primary_connection_string
    "WEBSITE_NODE_DEFAULT_VERSION" = "6.5.0"
  }
}
