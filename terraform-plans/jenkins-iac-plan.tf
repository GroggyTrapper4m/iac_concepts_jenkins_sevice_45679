terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "jenkins_poc" {
  name     = "rg-jenkins-demo"
  location = "East US"
}

resource "azurerm_storage_account" "jenkins_storage" {
  name                     = "stjenkinsdata${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.jenkins_poc.name
  location                 = azurerm_resource_group.jenkins_poc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "jenkins_share" {
  name               = "jenkins-home"
  storage_account_id = azurerm_storage_account.jenkins_storage.id
  quota              = 5
}

resource "azurerm_container_app_environment" "jenkins_env" {
  name                = "cae-jenkins"
  location            = azurerm_resource_group.jenkins_poc.location
  resource_group_name = azurerm_resource_group.jenkins_poc.name
}

#Storage area 
resource "azurerm_container_app_environment_storage" "jenkins_volume" {
  name                         = "jenkins-volume"
  container_app_environment_id = azurerm_container_app_environment.jenkins_env.id
  account_name                 = azurerm_storage_account.jenkins_storage.name
  share_name                   = azurerm_storage_share.jenkins_share.name
  access_key                   = azurerm_storage_account.jenkins_storage.primary_access_key
  access_mode                  = "ReadWrite"
}

# Jenkins Container
resource "azurerm_container_app" "jenkins_app" {
  name                         = "jenkins-service"
  container_app_environment_id = azurerm_container_app_environment.jenkins_env.id
  resource_group_name          = azurerm_resource_group.jenkins_poc.name
  revision_mode                = "Single"

  # Set up our application image needs.
  template {

    #Mounted our volume created
    volume {
      name         = "jenkins-volume"
      storage_name = azurerm_container_app_environment_storage.jenkins_volume.name
    }


    container {
      name   = "jenkins"
      image  = "jenkins/jenkins:lts"
      cpu    = 1
      memory = "2Gi"

      #Correct file permissions that Jenkins may have.
      command = ["/bin/sh"]
      args = [
        "-c",
        "chown -R 1000:1000 /var/jenkins_home && exec /usr/bin/tini -- /usr/local/bin/jenkins.sh"
      ]

      # Mount volume (this will need to be changed to Azure Storage)
      volume_mounts {
        name = "jenkins-volume"
        path = "/var/jenkins_home"
      }
    }
  }

  ingress {
    #allow for external access.
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      percentage = 70
      #optional,
      latest_revision = true
    }
  }
}

#ID for storage account, set random length
resource "random_id" "suffix" {
  byte_length = 4

}

# Recovery process
resource "azurerm_recovery_services_vault" "jenkins_vault" {
  name                = "rv-jenkins-backups"
  location            = azurerm_resource_group.jenkins_poc.location
  resource_group_name = azurerm_resource_group.jenkins_poc.name
  sku                 = "Standard"
  soft_delete_enabled = true
}
# Define retention policy (For now Daily, Midnight)
resource "azurerm_backup_policy_file_share" "jenkins_policy" {
  name                = "policy-jenkins-daily"
  resource_group_name = azurerm_resource_group.jenkins_poc.name
  recovery_vault_name = azurerm_recovery_services_vault.jenkins_vault.name
  timezone            = "Eastern Standard Time"

  backup {
    frequency = "Daily"
    time      = "00:00"
  }

  #set recovery points
  retention_daily {
    count = 10
  }
}


# Set up proper file share for retention policy
resource "azurerm_backup_container_storage_account" "protection_container" {
  resource_group_name = azurerm_resource_group.jenkins_poc.name
  recovery_vault_name = azurerm_recovery_services_vault.jenkins_vault.name
  storage_account_id  = azurerm_storage_account.jenkins_storage.id
}

# Protection, relay on the storage_account (protection_container), outlined above
resource "azurerm_backup_protected_file_share" "share_protection" {
  resource_group_name       = azurerm_resource_group.jenkins_poc.name
  recovery_vault_name       = azurerm_recovery_services_vault.jenkins_vault.name
  source_storage_account_id = azurerm_storage_account.jenkins_storage.id
  source_file_share_name    = azurerm_storage_share.jenkins_share.name
  backup_policy_id          = azurerm_backup_policy_file_share.jenkins_policy.id

  depends_on = [azurerm_backup_container_storage_account.protection_container]

}
