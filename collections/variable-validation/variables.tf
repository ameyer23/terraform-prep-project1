
variable "cloud" {
  type = string

    #no defaults set so user will be asked to input value. error message will pass accordingly. 
    #ensures users are entering correct variable values
  validation {
    condition     = contains(["aws", "azure", "gcp", "vmware"], lower(var.cloud))
    error_message = "You must use an approved cloud."
  }

  validation {
    condition     = lower(var.cloud) == var.cloud
    error_message = "The cloud name must not have capital letters."
  }
}

variable "no_caps" {
    type = string

    validation {
        condition = lower(var.no_caps) == var.no_caps
        error_message = "Value must be in all lower case."
    }

}

variable "character_limit" {
    type = string

    validation {
        condition = length(var.character_limit) == 3
        error_message = "This variable must contain only 3 characters."
    }
}

variable "ip_address" {
    type = string

    validation {
        condition = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
        error_message = "Must be an IP address of the form X.X.X.X."
    }
}


variable "phone_number" {
  type = string
  sensitive = true  #cant output this
  #default = "####"     #remove default to set env vars
}
