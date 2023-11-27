terraform {
  required_version = ">= 1.6.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.82.0"
    }
  }
}