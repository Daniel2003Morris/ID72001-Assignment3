terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Credentials come from the environment. In AWS Academy Learner Lab, copy them
# from the console into ~/.aws/credentials each session -- they expire every
# few hours. Never put them in a .tf file.
provider "aws" {
  region = var.region
}
