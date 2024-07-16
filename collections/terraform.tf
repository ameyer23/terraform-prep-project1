# Setting Terraform and AWS Provider vesions 
# Helpful for when codebase is not yet updated to keep up with new versions
# This downlods the latest AWS version that matches the constraint

#OG

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = { #AWS provider
      source  = "hashicorp/aws"
      version = ">= 3.0" #initial constratint
    }
    http = { #HTTP provider
      source  = "hashicorp/http"
      version = "3.4.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2" #former 3.6.2
    }
    local = { #used to manage local resources
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    tls = {
      source  = "hashicorp/tls" #used to create SSH Key
      version = "4.0.5"
    }
  }
}


