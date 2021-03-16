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

# Create Bastion Server IAM Role within AWS
resource "aws_iam_role" "bastion" {
  name               = "${local.prefix}-bastion"
  assume_role_policy = file("./templates/bastion/instance-profile-policy.json")

  tags = local.common_tags
}

### Bastion Server Policy Attachments to Bastion Rule

# Give Bastion Server access to AWS ECR read only via AWS policy attachment
resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

## more policy attachments might follow here...

######################################################

# Create instance profile in order to set it on the actual instance
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro" # should be enough for bastion server
  user_data            = file("./templates/bastion/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.bastion.name # created one block earlier
  key_name             = var.bastion_key_name
  subnet_id            = aws_subnet.public_a.id
  # Bastion is not a critcial resource we just launch into AZ A
  # In case of emergency we could launch a second instance into AZ B

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-bastion")
  )

}
