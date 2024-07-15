
# Add random provider
resource "random_pet" "server" {
  length = 2
}


module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
}