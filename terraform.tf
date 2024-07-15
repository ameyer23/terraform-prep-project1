# Setting Terraform and AWS Provider vesions 
# Helpful for when codebase is not yet updated to keep up with new versions
# This downlods the latest AWS version that matches the constraint

terraform {
  #backend "s3" {
    #bucket = "terraprep1-statefile"
    #key    = "prod/aws_infra"     # path within the S3 bucket where the Terraform state file is stored
    #region = "us-east-1"
    backend "local" {
      path = "terraform.tfstate"
      }
  
  required_version = ">= 1.0.0"
  required_providers {
    aws = {                       #AWS provider
      source  = "hashicorp/aws"
      version = ">= 3.0" #initial constratint
      #version = "3.76.1"            #latest version
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