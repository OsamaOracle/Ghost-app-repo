####################################################################################################
# VPC
####################################################################################################
resource "aws_vpc" "main" {
  cidr_block = tostring(var.vpc_cidr_block)
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

####################################################################################################
# Subnets
####################################################################################################
resource "aws_subnet" "public_subnet" {
  count      = tostring(length(var.public_subnet_cidr_block))

  vpc_id     = tostring(aws_vpc.main.id)
  cidr_block = tostring(element(var.public_subnet_cidr_block, count.index))

  availability_zone = tostring(element(var.availability_zones, count.index))

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_subnet" "database_subnet" {
  count      = tostring(length(var.database_subnet_cidr_block))

  vpc_id     = tostring(aws_vpc.main.id)
  cidr_block = tostring(element(var.database_subnet_cidr_block, count.index))

  availability_zone = tostring(element(var.availability_zones, count.index))

  tags = {
    Name = "database_subnet_${count.index}"
  }
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "database_subnet_group"
  subnet_ids = aws_subnet.database_subnet.*.id

  tags = {
    Name = "database_subnet_group"
  }
}

####################################################################################################
# Internet Gateway
####################################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = tostring(aws_vpc.main.id)
}

####################################################################################################
# Public Route Table
####################################################################################################
resource "aws_route_table" "public_route_table" {
  vpc_id = tostring(aws_vpc.main.id)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = tostring(aws_internet_gateway.igw.id)
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_main_route_table_association" "public_main_rt_association" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rt_association" {
  count = tostring(length(aws_subnet.public_subnet.*.id))

  subnet_id      = tostring(element(aws_subnet.public_subnet.*.id, count.index))
  route_table_id = tostring(aws_route_table.public_route_table.id)
}

####################################################################################################
# Private Database Route Table
####################################################################################################
resource "aws_route_table" "database_route_table" {
  vpc_id = tostring(aws_vpc.main.id)

  tags = {
    Name = "database_route_table"
  }
}

resource "aws_route_table_association" "database_rt_association" {
  count = tostring(length(aws_subnet.database_subnet.*.id))

  subnet_id      = tostring(element(aws_subnet.database_subnet.*.id, count.index))
  route_table_id = tostring(aws_route_table.database_route_table.id)
}

####################################################################################################
# Security groups
####################################################################################################
resource "aws_security_group" "mysql" {
  name        = "mysql"
  vpc_id      = tostring(aws_vpc.main.id)

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = aws_subnet.public_subnet.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_security_group"
  }
}

resource "aws_security_group" "application" {
  name        = "application"
  vpc_id      = tostring(aws_vpc.main.id)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application_security_group"
  }
}

####################################################################################################
# Public NACLs
####################################################################################################
resource "aws_network_acl" "public_nacls" {
  vpc_id        = aws_vpc.main.id
  subnet_ids    = aws_subnet.public_subnet.*.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "public_nacls"
  }
}

####################################################################################################
# Private Database NACLs
####################################################################################################
resource "aws_network_acl" "database_nacls" {
  vpc_id = aws_vpc.main.id
  subnet_ids    = aws_subnet.database_subnet.*.id

  dynamic "egress" {
    for_each = [for idx, subnet in aws_subnet.public_subnet : {
      rule_no     = 100 + idx
      cidr_block  = subnet.cidr_block
    }]
    content {
      protocol   = -1
      rule_no    = egress.value["rule_no"]
      action     = "allow"
      cidr_block = egress.value["cidr_block"]
      from_port  = 0
      to_port    = 0
    }
  }

  dynamic "ingress" {
    for_each = [for idx, subnet in aws_subnet.public_subnet : {
      rule_no     = 100 + idx
      cidr_block  = subnet.cidr_block
    }]
    content {
      protocol   = "tcp"
      rule_no    = ingress.value["rule_no"]
      action     = "allow"
      cidr_block = ingress.value["cidr_block"]
      from_port  = 3306
      to_port    = 3306
    }
  }

  tags = {
    Name = "database_nacls"
  }
}
