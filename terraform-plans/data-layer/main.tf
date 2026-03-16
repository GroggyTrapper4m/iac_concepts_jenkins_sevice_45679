# terraform {
#   1. Note: Storage is not being managed by terraform, leaving it as a reference point. 
#   This file is being left as a reference point if it was being created as a part of the rg.
#   Reason being the IOPS of Azure shares is a bit slow on standard file type, leaving it sit idle and connect as needed.
#   backend "azurerm" {
#     resource_group_name  = "XXXXXXXXXXXX"
#     storage_account_name = "XXXXXXXXXXXX"
#     container_name       = "tfstate"
#     key                  = "jenkins-data.tfstate"
#   }

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.0"
#     }
#   }
# }

# provider "azurerm" {
#   features {}
#   resource_provider_registrations = "core"
# }

# Note: The container app-environment already exists, but leaving block to recreate if needed. 
# The app-layer is referencing the existing container environment for the Jenkins container boundary.
# Keeping should we need it recreated later
# resource "azurerm_container_app_environment" "jenkins_env" {
#   name                = "cae-jenkins"
#   location            = var.location
#   resource_group_name = data.azurerm_storage_account.permanent.resource_group_name
# }

# Note: This resource already exists, but leaving block here to recreate if needed.
# resource "azurerm_container_app_environment_storage" "jenkins_volume" {
#   name                         = "jenkins-volume"
#   container_app_environment_id = azurerm_container_app_environment.jenkins_env.id
#   account_name                 = data.azurerm_storage_account.permanent.name
#   share_name                   = "jenkins-home"
#   access_key                   = data.azurerm_storage_account.permanent.primary_access_key
#   access_mode                  = "ReadWrite"
# }


# Note: This resource group is not being used, but could be a separate area outside of the container app and it's
# environment.
#resource "azurerm_resource_group" "jenkins_data_rg" {
#  name     = var.group-name
#  location = var.location
#}

#resource "random_id" "suffix" {
#  byte_length = 4
#}

# Note: Main storage use here is a bit slow; but will re-create as needed.
#resource "azurerm_storage_account" "jenkins_storage" {
#  name                     = "stjenkinsdata${random_id.suffix.hex}"
#  resource_group_name      = azurerm_resource_group.jenkins_data_rg.name
#  location                 = azurerm_resource_group.jenkins_data_rg.location
#  account_tier             = "Standard"
#  account_replication_type = "LRS"

#  lifecycle {
#    prevent_destroy = true
#  }
#}

# Create a resource of 5gb for jenkins storage to load data.
#resource "azurerm_storage_share" "jenkins_share" {
#  name               = "jenkins-home"
#  storage_account_id = azurerm_storage_account.jenkins_storage.id
#  quota              = 5
#}

# Upon creation, provide us the names of newly created resources.
#output "storage_account_name" {
#  value = azurerm_storage_account.jenkins_storage.name
#}

#output "resource_group_name" {
#  value = azurerm_resource_group.jenkins_data_rg.name
#}
