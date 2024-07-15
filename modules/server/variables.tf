
variable "ami" {}       #no default value = required input, should be included in module resource block in main
variable "size" {
  #default = "t3.micro"  #default values are optional inputs
}
variable "subnet_id" {}
variable "security_groups" {
  type = list(any)
}