terraform {

    required_providers {

        azurerm = {
        source  = "hashicorp/azurerm"
        version = "= 2.86.0"
        }

    }

 }

 provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "podconstraints" {
  name     = "podconstraints"
  location = "East Us"
}
