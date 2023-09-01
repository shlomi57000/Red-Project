# Create a local var
locals {
  azs = data.aws_availability_zones.available.names
}


# Create a availability zone
data "aws_availability_zones" "available" {}

# Create a rnd, for version tag
resource "random_id" "random" {
  byte_length = 2
}



# Create a VPC
resource "aws_vpc" "mtc_vpc_f" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc_gal-${random_id.random.dec}"
  }

  lifecycle {
    create_before_destroy = true
  }
}



# Create a gateway
resource "aws_internet_gateway" "mtc_int_gtwy" {
  vpc_id = aws_vpc.mtc_vpc_f.id
  tags = {
    Name = "gtwy_gal-${random_id.random.dec}"
  }
}



# Create a route_table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.mtc_vpc_f.id
  tags = {
    Name = "prt_gal-${random_id.random.dec}"
  }

}



# Create a public route
resource "aws_route" "default_public_rt" {
  route_table_id         = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_int_gtwy.id

}



# Create a private route
resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.mtc_vpc_f.default_route_table_id
  tags = {
    Name = "private_rt_gal-${random_id.random.dec}"
  }
}



# Create a public subnet
resource "aws_subnet" "mtc_public_subnet" {
  count = length(local.azs)
  vpc_id                  = aws_vpc.mtc_vpc_f.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "public_subnet_gal_${count.index + 1}-${random_id.random.dec}"
  }
}



# Create a private subnet
resource "aws_subnet" "mtc_private_subnet" {
  count = length(local.azs)
  vpc_id                  = aws_vpc.mtc_vpc_f.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "private_subnet_gal_${count.index + 1}-${random_id.random.dec}"
  }
}



resource "aws_route_table_association" "subnet_rt" {
  count = length(local.azs)
  subnet_id = aws_subnet.mtc_public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}



resource "aws_security_group" "sgrp" {
  name = "public_sg"
  description = "SG for public instances"
  vpc_id = aws_vpc.mtc_vpc_f.id
}



# Ingress to access instances to internal
resource "aws_security_group_rule" "sg_ingress_all" {
  type = "ingress"
  from_port = "0"
  to_port = "65535"
  protocol = "-1"
  cidr_blocks = [var.access_ip, var.hp_local_ip]
  security_group_id = aws_security_group.sgrp.id
}



# Egress to access instances to external
resource "aws_security_group_rule" "sg_egress_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sgrp.id
}