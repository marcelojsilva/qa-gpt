variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy the infrastructure in"
}

variable "availability_zones" {
  description = "A list of availability zones to use for subnets"
  type        = list(string)
  default     = ["a", "b"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.main.id

  availability_zone = "${var.region}${element(var.availability_zones, count.index)}"
  tags = {
    Name = "${var.app_name}-public-subnet-${count.index + 1}"
  }

}

resource "aws_subnet" "private" {
  count = 2

  cidr_block = "10.0.${count.index + 101}.0/24"
  vpc_id     = aws_vpc.main.id

  availability_zone = "${var.region}${element(var.availability_zones, count.index)}"
  tags = {
    Name = "${var.app_name}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "subnet_id" {
  value = aws_subnet.private[0].id
}