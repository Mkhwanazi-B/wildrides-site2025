# Example: In your versions.tf file (at the root of your Terraform project)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Make sure this is set to require version 6.x
    }
  }
  required_version = ">= 1.12.0" # Or higher, to match your CLI
}