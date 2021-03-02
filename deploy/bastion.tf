# Amazon Linux 2 AMI (HVM)
# AMI Name -> AWS Console -> EC2 -> AMIs -> Search for 'ami-0915bcb5fa77e4892'
# Result: amzn2-ami-hvm-2.0.20210219.0-x86_64-gp2
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name = "name"
    # Wildcard for getting the latest one
    values = ["amzn2-ami-hvm-2.0.*.0-x86_64-gp2"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" # should be enough for bastion server

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-bastion")
  )

}
