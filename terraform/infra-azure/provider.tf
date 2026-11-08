terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# The features block is mandatory for the azurerm provider, even when empty.
provider "azurerm" {
  features {}

  # Student subscriptions often lack permission to register resource
  # providers. If `terraform apply` fails with a registration error, leave
  # this false and ask your lecturer to register the namespace, or register
  # it once yourself with:
  #   az provider register --namespace Microsoft.Compute
  resource_provider_registrations = "none"

  # Uncomment and set if your account has access to more than one
  # subscription, so Terraform cannot pick the wrong one.
  # subscription_id = "00000000-0000-0000-0000-000000000000"
}
