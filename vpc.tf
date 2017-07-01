# Resource keys for ssh into aws ec2 instances
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

# creating Primary VPC  
resource "aws_vpc" "primary-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name = "primary-vpc"
  }
}

# Creating public subnet for primary vpc
resource "aws_subnet" "primary-public-1" {
  vpc_id                  = "${aws_vpc.primary-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2a"

  tags {
    Name = "primary-public-1"
  }
}

# Creating private subnet for primary vpc
resource "aws_subnet" "primary-private-1" {
  vpc_id                  = "${aws_vpc.primary-vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-2a"

  tags {
    Name = "primary-private-1"
  }
}

# Creating internet gateway for primary vpc 
resource "aws_internet_gateway" "primary-vpc-igw" {
  vpc_id = "${aws_vpc.primary-vpc.id}"

  tags {
    Name = "primary-vpc-igw"
  }
}

# Creating route table for private subnet
resource "aws_route_table" "primary-vpc-private" {
  vpc_id = "${aws_vpc.primary-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.primary-nat-gw.id}"
  }

  tags {
    Name = "primary-vpc-private"
  }
}

# Creating secondary vpc 
resource "aws_vpc" "secondary-vpc" {
  cidr_block           = "172.30.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name = "secondary-vpc"
  }
}

# Creating public subnet for secondary vpc
resource "aws_subnet" "secondary-public-1" {
  vpc_id                  = "${aws_vpc.secondary-vpc.id}"
  cidr_block              = "172.30.131.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2a"

  tags {
    Name = "secondary-public-1"
  }
}

resource "aws_vpc_endpoint" "private-s3" {
  vpc_id          = "${aws_vpc.secondary-vpc.id}"
  service_name    = "com.amazonaws.us-east-2.s3"
  route_table_ids = ["${aws_route_table.secondary-vpc-private.id}"]
}

# Creating private subnet for secondary vpc
resource "aws_subnet" "secondary-private-1" {
  vpc_id                  = "${aws_vpc.secondary-vpc.id}"
  cidr_block              = "172.30.132.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-2a"

  tags {
    Name = "secondary-private-1"
  }
}

# Creating internet gateway for secondary vpc
resource "aws_internet_gateway" "secondary-vpc-igw" {
  vpc_id = "${aws_vpc.secondary-vpc.id}"

  tags {
    Name = "secondary-vpc-igw"
  }
}

# Creating route table for secondary vpc private
resource "aws_route_table" "secondary-vpc-private" {
  vpc_id = "${aws_vpc.secondary-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.secondary-nat-gw.id}"
  }

  tags {
    Name = "secondary-vpc-private"
  }
}

# Make AWS account ID available.
data "aws_caller_identity" "current" {}

# VPC peering connection
resource "aws_vpc_peering_connection" "primary2secondary" {
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = "${aws_vpc.secondary-vpc.id}"
  vpc_id        = "${aws_vpc.primary-vpc.id}"
  auto_accept   = true

  tags {
    Name = "VPC Peering Primary/Secondary"
  }
}

# Creating routing table for primary vpc
resource "aws_route_table" "primary-vpc-public" {
  vpc_id = "${aws_vpc.primary-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.primary-vpc-igw.id}"
  }

  route {
    cidr_block                = "${aws_vpc.secondary-vpc.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
  }

  tags {
    Name = "primary-vpc-public"
  }
}

# Creating route table for secondary vpc
resource "aws_route_table" "secondary-vpc-public" {
  vpc_id = "${aws_vpc.secondary-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.secondary-vpc-igw.id}"
  }

  route {
    cidr_block                = "${aws_vpc.primary-vpc.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
  }

  tags {
    Name = "secondary-vpc-public"
  }
}

# route associations for secondary vpc public subnet
resource "aws_route_table_association" "main-secondary-vpc-public" {
  subnet_id      = "${aws_subnet.secondary-public-1.id}"
  route_table_id = "${aws_route_table.secondary-vpc-public.id}"
}

# Associating route table to primary public subnet
resource "aws_route_table_association" "main-primary-vpc-public" {
  subnet_id      = "${aws_subnet.primary-public-1.id}"
  route_table_id = "${aws_route_table.primary-vpc-public.id}"
}

# route associations for secondary vpc private subnet
resource "aws_route_table_association" "main-secondary-vpc-private" {
  subnet_id      = "${aws_subnet.secondary-private-1.id}"
  route_table_id = "${aws_route_table.secondary-vpc-private.id}"
}

# Associating route table to private subnet
resource "aws_route_table_association" "main-primary-vpc-private" {
  subnet_id      = "${aws_subnet.primary-private-1.id}"
  route_table_id = "${aws_route_table.primary-vpc-private.id}"
}
