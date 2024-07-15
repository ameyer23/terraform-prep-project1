
/* 
contains output definitions for the module 

Module outputs are made available to the configuration using the module, so they 
are often used to pass information about the parts of your infrastructure defined 
by the module to other parts of your configuration.

*/

output "public_ip" {
  description = "IP Address of server built with server module"
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}


output "size" {
  description = "Size of server built with Server Module"
  value       = aws_instance.web.instance_type
}

