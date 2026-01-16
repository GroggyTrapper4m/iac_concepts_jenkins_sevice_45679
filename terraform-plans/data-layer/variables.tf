variable "location" {
  type        = string
  default     = "East US"
  description = "Location of the storage account."
}

variable "group-name" {
  type        = string
  default     = "rg-group-name"
  description = "Name of your resource group."
}

variable "name-of-share" {
  type        = string
  default     = "jenkins-home"
  description = "Share name."
}
