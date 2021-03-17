resource "aws_docdb_subnet_group" "main" {
  name = "${local.prefix}-main"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )
}

resource "aws_security_group" "docdb" {
  description = "Allow access to aws docdb cluster instance"
  name        = "${local.prefix}-docdb-inbound-access"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol  = "tcp"
    from_port = 27017
    to_port   = 27017

    security_groups = [ # limit access to this groups only
      aws_security_group.bastion.id,
      aws_security_group.ecs_service.id,
    ]
  }

  tags = local.common_tags
}

# Defining a parameter group for cluster

resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "docdb3.6"
  name        = "${local.prefix}-docdb-parameter-group"
  description = "docdb cluster parameter group for cluster"

  parameter {
    name         = "tls"
    value        = "enabled"
    apply_method = "immediate"
  }

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )
}

# Defining main AWS docdb cluster

resource "aws_docdb_cluster" "main" {
  cluster_identifier              = "${local.prefix}-docdb-cluster"
  db_subnet_group_name            = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
  # availability_zones      = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
  # cluster wants to live zone c as well so commenting this out prevents force recreation on every commit
  port                    = 27017
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 1
  skip_final_snapshot     = true

  vpc_security_group_ids = [aws_security_group.docdb.id]

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )

}

# Cluster instance in availability zone A

resource "aws_docdb_cluster_instance" "db_zone_a" {
  identifier         = "${local.prefix}-docdb-instance-a"
  availability_zone  = "${data.aws_region.current.name}a"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.t3.medium"
  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-db-a")
  )
}

# Cluster instance in availability zone B

resource "aws_docdb_cluster_instance" "db_zone_b" {
  identifier         = "${local.prefix}-docdb-instance-b"
  availability_zone  = "${data.aws_region.current.name}b"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = "db.t3.medium"
  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-db-b")
  )
}


