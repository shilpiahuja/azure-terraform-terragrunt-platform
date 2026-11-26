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
  default     = "rg-platform-dev"
}
