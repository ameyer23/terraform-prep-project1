# Setting Terraform and AWS Provider vesions 
# Helpful for when codebase is not yet updated to keep up with new versions
# This downlods the latest AWS version that matches the constraint

terraform {
 backend "remote" {
    hostname = "app.terraform.io"   #name of my enterprise server
    organization = "ameyer_terra" #my org name from terra workspaces

    workspaces {    #terra cloud workspace
      name = "my-aws-app"
    }
  }


  #required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}