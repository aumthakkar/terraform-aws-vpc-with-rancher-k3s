# --- networking/main.tf ---

data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "pht_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "pht-vpc-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "pht_public_subnets" {
  count = var.public_sn_count

  vpc_id            = aws_vpc.pht_vpc.id
  cidr_block        = var.public_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "pht-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "pht_public_route_table_assoc" {
  count = var.public_sn_count

  subnet_id      = aws_subnet.pht_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.pht_public_route_table.id

}

resource "aws_subnet" "pht_private_subnet" {
  count = var.private_sn_count

  vpc_id            = aws_vpc.pht_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "pht-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "pht_igw" {
  vpc_id = aws_vpc.pht_vpc.id

  tags = {
    Name = "pht-igw"
  }
}

resource "aws_route_table" "pht_public_route_table" {
  vpc_id = aws_vpc.pht_vpc.id

  tags = {
    Name = "pht-public-route-table"
  }
}

resource "aws_route" "pht_public_rt" {
  route_table_id = aws_route_table.pht_public_route_table.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pht_igw.id

}

resource "aws_default_route_table" "pht_private_route_table" {
  default_route_table_id = aws_vpc.pht_vpc.default_route_table_id

  tags = {
    Name = "pht-private-route-table"
  }
}

resource "aws_security_group" "pht_sg" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.pht_vpc.id

  tags = each.value.tags
}

resource "aws_db_subnet_group" "pht_rds_subnetgroup" {
  count = var.db_subnet_group ? 1 : 0

  name       = "pht-db-subnetgroup"
  subnet_ids = aws_subnet.pht_private_subnet.*.id
}