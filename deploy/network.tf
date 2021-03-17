resource "aws_vpc" "main" {  # One VPC per environment
  cidr_block = "10.1.0.0/16" # Mask for what IP addresses are available in VPC
  # Network Cheat Sheet: https://www.aelius.com/njh/subnet_sheet.html
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-vpc")
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )

}

####################################################
# Public Subnets - Inbound/Outbund Internet Access #
####################################################

######### Public A ############

resource "aws_subnet" "public_a" {
  cidr_block = "10.1.1.0/24" # => 254 host per subnet
  # Range 10.1.1.X (X = 0-254)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )

}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

# Give internet access to public subnet in availability zone A
resource "aws_route" "public_internet_access_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0" # all addresses
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "public_a" {
  vpc = true

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )
}

# NAT Gateway to allow private subnet A outbound internet access only
# via public subnet A's elastic ip
resource "aws_nat_gateway" "public_a" {
  allocation_id = aws_eip.public_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-a")
  )

}

######### Public B ############

resource "aws_subnet" "public_b" {
  cidr_block = "10.1.2.0/24" # => 254 host per subnet
  # Range 10.1.2.X (X = 0-254)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

# Give internet access to public subnet in availability zone B
resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0" # all addresses
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "public_b" {
  vpc = true # create it inside the vpc

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

# NAT Gateway to allow private subnet B outbound internet access only
# via public subnet B's elastic ip
resource "aws_nat_gateway" "public_b" {
  allocation_id = aws_eip.public_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-public-b")
  )
}

####################################################
# Private Subnets - Outbund Internet Access only   #
####################################################

######### Private A ############

resource "aws_subnet" "private_a" {
  cidr_block = "10.1.10.0/24" # => 254 host per subnet
  # Range 10.1.10.X (X = 0-254)
  # 10.1.3.X to 10.1.9.X still available for public subnets if needed
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-private-a")
  )
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-private-a")
  )
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route" "private_a_internet_out" {
  route_table_id = aws_route_table.private_a.id
  # Private A Subnet has no direct outbound internet access
  # So its utilizing public A subnets NAT gateway for restricetd outbound internet access
  nat_gateway_id         = aws_nat_gateway.public_a.id
  destination_cidr_block = "0.0.0.0/0"
}

######### Private AB ############

resource "aws_subnet" "private_b" {
  cidr_block = "10.1.11.0/24" # => 254 host per subnet
  # Range 10.1.11.X (X = 0-254)
  # 10.1.3.X to 10.1.9.X still available for public subnets if needed
  vpc_id            = aws_vpc.main.id
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-private-b")
  )
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-private-b")
  )
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route" "private_b_internet_out" {
  route_table_id = aws_route_table.private_b.id
  # Private B Subnet has no direct outbound internet access
  # So its utilizing public B subnets NAT gateway for restricetd outbound internet access
  nat_gateway_id         = aws_nat_gateway.public_b.id
  destination_cidr_block = "0.0.0.0/0"
}


