variable "username" {
  description = "Your student username. Prefixes every resource name so the whole class can apply into one account."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.username))
    error_message = "Use 3-20 lowercase letters, digits or hyphens."
  }
}

variable "region" {
  description = "AWS region. Learner Lab permits us-east-1 and us-west-2 only."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Learner Lab only permits us-east-1 or us-west-2."
  }
}

variable "instance_type" {
  description = "Needs 2 vCPU and 8 GiB. t3.medium (4 GiB) will OOM once the observability stack starts."
  type        = string
  default     = "t3.large"
}

variable "admin_username" {
  description = "Default login account in Canonical's Ubuntu AMIs."
  type        = string
  default     = "ubuntu"
}

variable "public_key_path" {
  description = "Path to the SSH public key to install on the instance."
  type        = string
  default     = "./k8s-key.pub"
}

variable "ssh_source_cidr" {
  description = "Source range permitted to reach SSH. Set this to <your-ip>/32; 0.0.0.0/0 is the lazy default and you will be asked to justify it."
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.72.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.72.1.0/24"
}

variable "root_disk_size_gb" {
  description = "Root volume size in GiB."
  type        = number
  default     = 40
}

variable "data_disk_size_gb" {
  description = "Dedicated EBS data volume in GiB. Learner Lab caps volumes at 100 GiB."
  type        = number
  default     = 32

  validation {
    condition     = var.data_disk_size_gb >= 8 && var.data_disk_size_gb <= 100
    error_message = "Learner Lab permits volumes between 8 and 100 GiB."
  }
}
