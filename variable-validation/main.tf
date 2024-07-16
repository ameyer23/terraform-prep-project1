locals {
  contact_info = {
      cloud = var.cloud
      department = var.no_caps
      cost_code = var.character_limit
      phone_number = var.phone_number
  }

  my_number = nonsensitive(var.phone_number)
}

output "cloud" {
  value = local.contact_info.cloud
}

output "department" {
  value = local.contact_info.department
}

output "cost_code" {
  value = local.contact_info.cost_code
}

output "phone_number" {
  value = local.contact_info.phone_number
  sensitive = true
}

output "my_number" {
  value = local.my_number
}

