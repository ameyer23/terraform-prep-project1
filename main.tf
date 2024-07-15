# Configure the AWS Provider - contains credentials 
provider "aws" {
  region  = "us-east-1"   #not specifying workspaces
  profile = var.profile_name

  default_tags { #tags all terraform resources 
    tags = {
      Environment = local.environment
      Owner       = "andrea"
      Provisioned = "Terraform"
    }
  }
}

#Retrieve the list of AZs in the current AWS region
#NOTE: Data blocks are used to query APIs (like AWS) of other workspaces
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}



# Terraform Data Block - Lookup Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]

  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


#Create  local variables 
# region and enviroment map workspaces to regions 
locals {
  team        = "api_mgmt_dev"
  application = "corp_api"
  server_name = "2-terraprep1-ec2-${var.environment}-api-${var.variables_sub_az}"
  #region = "us-east-1"          #not specifying workspaces
  region      = terraform.workspace == "default" ? "us-east-1" : "us-west-2" #specify workspace, using local variable
  environment = terraform.workspace == "default" ? "production" : "development"


}

#Define the VPC 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    #Name        = var.vpc_name
    Name        = "${var.vpc_name}-${local.environment}" #name containts workspace name
    Environment = "terra-prep1-environment"
    Terraform   = "true"
    Region      = data.aws_region.current.name #the aws_region data source has 3 possible attributes (name, endpoint, description)
  }
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id     = aws_internet_gateway.internet_gateway.id
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_private_rtb"
    Terraform = "true"
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo_igw_eip"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "demo_nat_gateway"
  }
}


# Terraform Resource Block - To Build EC2 Ubuntu web server instance in Public Subnet 
resource "aws_instance" "ubuntu_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnets["public_subnet_1"].id
  security_groups             = [aws_security_group.vpc-ping.id, aws_security_group.ingress-ssh.id, aws_security_group.vpc-web.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name #associate key
  connection {                                                  #connection block: defines how to connect to server 
    #type        = "ssh"
    user        = "ubuntu" #username that connects to server
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
    #agent       = false
  }

  # set local-exec provisioner - local command that ensures private key is permissioned correctly
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
    #command = "chmod 600 MyAWSKey.pem"
  }

  # set remote-exec provisioner - runs remote commands on remote resource which is the Terra instance
  # provisioner can clone web application code to the instance and then invoke the setup script
  provisioner "remote-exec" {
    inline = [ #list of commands to be executed by provisioner on instance
      #"exit 2", # server will error out. This condition can be used to handle failures in scripts
      "sudo rm -rf /tmp",                                                    #cleanup tmp directory on server 
      "sudo git clone https://github.com/hashicorp/demo-terraform-101 /tmp", #clone web app from repo
      "sudo sh /tmp/assets/setup-web.sh",                                    # web app deployment script path
    ]
  }

  tags = {
    Name = "Ubuntu EC2 Web Server"
  }


}


# Generate TLS self signed certificate and saving the private key locally
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

# Generate file that contains private key
resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}


# Generate an AWS SSH key pair for instance
resource "aws_key_pair" "generated" {
  key_name   = "MyAWSKey" #key name in aws
  public_key = tls_private_key.generated.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}


# Security Groups that allows SSH traffic
# SSH is required for remote-exec provisioner to communicate with remote instance 
resource "aws_security_group" "ingress-ssh" {
  name   = "allow-all-ssh"
  vpc_id = aws_vpc.vpc.id

  # Allow SSH access from any IP address
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  // Terraform removes the default rule
  egress {
    description = "Allow all IP and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Groups that allows web traffic over HTTP and HTTPS 
resource "aws_security_group" "vpc-web" {
  name        = "vpc-web-${terraform.workspace}"
  vpc_id      = aws_vpc.vpc.id
  description = "Web Traffic"
  ingress {
    description = "Allow Port 80" #HTTP and HTTPS
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group to Allow Ping Traffic
resource "aws_security_group" "vpc-ping" {
  name        = "vpc-ping"
  vpc_id      = aws_vpc.vpc.id
  description = "ICMP for Ping Access"
  ingress {
    description = "Allow ICMP Traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


