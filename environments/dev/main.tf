terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

variable "subscription_id" {
  description = "Azure subscription used for the dev environment."
  type        = string
}

variable "location" {
  description = "Azure region for development resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the development resource group."
  type        = string
}

variable "tags" {
  description = "Tags applied to development resources."
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

output "resource_group_name" {
  description = "Name of the development resource group."
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "Azure resource ID of the development resource group."
  value       = module.resource_group.id
}
