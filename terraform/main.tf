terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 3.19.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-${var.environment}-resource-group"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.project}${var.environment}storage"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "Node.JS"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "my_linux_function_app" {
  name                       = "my-linux-function-app-13dp5dv"
  resource_group_name        = azurerm_resource_group.resource_group.name
  location                   = var.location
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      node_version = 16
    }
  }
}

# resource "azurerm_function_app" "function_app" {
#   name                = "${var.project}-${var.environment}-function-app"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = var.location
#   app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
#   app_settings = {
#     "WEBSITE_RUN_FROM_PACKAGE"       = "",
#     "FUNCTIONS_WORKER_RUNTIME"       = "node",
#     "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key,
#   }
#   os_type = "linux"
#   site_config {
#     linux_fx_version          = "node|14"
#     use_32_bit_worker_process = false
#   }
#   storage_account_name       = azurerm_storage_account.storage_account.name
#   storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
#   version                    = "~3"

#   lifecycle {
#     ignore_changes = [
#       app_settings["WEBSITE_RUN_FROM_PACKAGE"],
#     ]
#   }
# }
