resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16" # Mask for what IP addresses are available in VPC
  # Network Cheat Sheet: https://www.aelius.com/njh/subnet_sheet.html
  enable_dns_support  = true
  enable_dns_hostname = true

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
