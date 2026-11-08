variable "username" {
  description = "Your student username. Prefixes every resource name so the whole class can deploy into one subscription without collisions."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.username))
    error_message = "Use 3-20 lowercase letters, digits or hyphens."
  }
}

variable "dns_label" {
  description = "DNS label for the public IP. Produces <label>.<region>.cloudapp.azure.com, which must be GLOBALLY unique within the region -- include your username."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,61}[a-z0-9]$", var.dns_label))
    error_message = "Must start with a letter, end alphanumeric, and use only lowercase letters, digits and hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group to deploy into."
  type        = string
}

variable "create_resource_group" {
  description = "true to create the resource group, false to deploy into one that already exists. Student subscriptions are often issued with the group pre-created and creation blocked."
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region. Must be permitted by your subscription's Allowed Locations policy -- check the portal before assuming."
  type        = string
  default     = "australiaeast"
}

variable "vm_size" {
  description = "Must be large enough for MicroK8s plus the observability stack. 2 vCPU and 8 GiB is the practical minimum; a 4 GiB VM will OOM once kube-prometheus-stack starts."
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "Linux administrator account on the VM."
  type        = string
  default     = "azureuser"
}

variable "public_key_path" {
  description = "Path to the SSH public key to install on the VM."
  type        = string
  default     = "./k8s-key.pub"
}

variable "ssh_source_cidr" {
  description = "Source range permitted to reach SSH. Set this to your own address; 'Internet' is the lazy default and you will be asked to justify it."
  type        = string
  default     = "Internet"
}

variable "vnet_cidr" {
  description = "Address space for the virtual network."
  type        = string
  default     = "10.72.0.0/16"
}

variable "subnet_cidr" {
  description = "Address prefix for the subnet."
  type        = string
  default     = "10.72.1.0/24"
}

variable "data_disk_size_gb" {
  description = "Size of the dedicated managed data disk, in GiB."
  type        = number
  default     = 32

  validation {
    condition     = var.data_disk_size_gb >= 8 && var.data_disk_size_gb <= 256
    error_message = "Use between 8 and 256 GiB."
  }
}
