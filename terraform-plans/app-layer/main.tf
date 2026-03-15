terraform {
  backend "azurerm" {
    resource_group_name  = "rg-jenkins-redeploy"
    storage_account_name = "stjenkinsdatafa4d29a1"
    container_name       = "tfstate"
    key                  = "jenkins-app.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "core"
}


data "azurerm_storage_account" "permanent" {
  name                = var.target_storage_account_name
  resource_group_name = "rg-jenkins-redeploy"
}

# 2. Find the existing azure container environment
data "azurerm_container_app_environment" "jenkins_env" {
  name                = "cae-jenkins"
  resource_group_name = "rg-jenkins-redeploy"
}

# 3. Find the existing Link (Storage Mount)
# Already exists within Azure.
# AzureRM doesn't yet support datablocks for app_environment storage
# Providing example if it did, like say AWS.
#data "azurerm_container_app_environment_storage" "jenkins_volume" {
#  name                         = "jenkins-volume"
#  container_app_environment_id = data.azurerm_container_app_environment.jenkins_env
#}

# Creation of Application The Jenkins App
# Notice extended environment values to get container up and running due to broken out storage area.
resource "azurerm_container_app" "jenkins_app" {
  name                         = "jenkins-service"
  container_app_environment_id = data.azurerm_container_app_environment.jenkins_env.id
  resource_group_name          = data.azurerm_container_app_environment.jenkins_env.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "jenkins"
      image  = "jenkins/jenkins:lts"
      cpu    = 2.0
      memory = "4Gi"

      env {
        name  = "JAVA_OPTS"
        value = "-Xmx3g -Xms1g -Djenkins.install.runSetupWizard=true -Dhudson.util.RingBufferLogHandler.defaultSize=50 -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York -Dhudson.FilePath.VALIDATE_ANT_FILE_MASK=false"
      }

      env {
        name  = "JENKINS_ADMIN_ID"
        value = var.jenkins_admin_id
      }
      env {
        name  = "JENKINS_ADMIN_PASSWORD"
        value = var.jenkins_admin_password
      }

      volume_mounts {
        name = "jenkins-volume-mount"
        path = "/var/jenkins_home"
      }
    }
    volume {
      name          = "jenkins-volume-mount"
      storage_name  = "jenkins-volume"
      storage_type  = "AzureFile"
      mount_options = "uid=1000,gid=1000,mfsymlinks,nobrl"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

output "jenkins_url" {
  description = "The public URL of the Jenkins service"
  value       = "https://${azurerm_container_app.jenkins_app.ingress[0].fqdn}"
}
