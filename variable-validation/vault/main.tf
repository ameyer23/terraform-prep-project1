provider "vault" {
  address = "http://127.0.0.1:8200"
  token = "hvs.MgSlIS0wbhSmFgdng2CT10tL" 
}

data "vault_generic_secret" "phone_number" {
  path = "secret/app"
}

#data being grabbed from vault
output "phone_number" {
  value = data.vault_generic_secret.phone_number.data["phone_number"]
  sensitive = true
}