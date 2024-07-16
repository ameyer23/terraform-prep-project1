provider "vault" {
  address = "http://127.0.0.1:8200"
  #token#goes#here = "<rootttoken?>" 
}

data "vault_generic_secret" "phone_number" {
  path = "secret/app"
}

#data being grabbed from vault
output "phone_number" {
  value = data.vault_generic_secret.phone_number.data["phone_number"]
  sensitive = true
}