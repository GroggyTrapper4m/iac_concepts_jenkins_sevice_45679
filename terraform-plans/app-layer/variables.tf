
variable "target_storage_account_name" {
  type        = string
  default     = "myAzureStorageGroup"
  description = "The name of existing storage account."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the infrastructure will live."
  default     = "rg-jenkins-deployment"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "jenkins_admin_id" {
  type        = string
  description = "The username for the initial admin account."
  default     = "admin"
}

variable "jenkins_admin_password" {
  type        = string
  description = "The password for the initial admin account"
  sensitive   = true
}
