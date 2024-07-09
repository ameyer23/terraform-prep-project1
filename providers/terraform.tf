
# Setting Terraform and AWS Provider vesions 
# Helpful for when codebase is not yet updated to keep up with new versions
# This downlods the latest AWS version that matches the constraint

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.0"           #initial constratint
      version = "3.76.1"            #latest version
    }
  }
}