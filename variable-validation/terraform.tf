terraform {
  backend "remote" {
    organization = "ameyer_terra"

    workspaces {
      name = "variable_validation"
    }
  }
}