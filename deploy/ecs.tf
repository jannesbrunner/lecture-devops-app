# AWS Elastic Container Server (ECS) is used to serve the app via running containers
# We use ECS with AWS Fargate (https://aws.amazon.com/de/fargate/) a serverless container computing engine

# define a ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

# Create <IAM Role Policy> for ECS service task from template
# This is giving task needed permissions like pulling images from ECR
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/" # just a way of organizing the aws policies
  description = "Allow retrieving of images and adding to logs"
  policy      = file("./templates/ecs/task-exec-role.json")
}

# Create <IAM Role> in AWS with assumed role from template
resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

# Attach created <IAM Role Policy> to created <IAM Role>
resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}


# Give ECS Task permissions at runtime with created <IAM Role>:
resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-server-app-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

# Create a AWS Cloudwatch log group for ECS task that is running the server containers
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-server-containers"

  tags = local.common_tags
}

# Template file for defining app containers that ECS will run
# vars get rendered later within the template file
data "template_file" "app_container_definitions" {
  template = file("./templates/ecs/container-definitions.json.tpl")

  vars = {
    app_image        = var.ecr_image_server
    db_image         = var.ecr_image_db
    log_group_name   = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region = data.aws_region.current.name
    allowed_hosts    = aws_lb.todo_server.dns_name
  }
}

# Creating ECS Task
resource "aws_ecs_task_definition" "server" {
  family                   = "${local.prefix}-server"
  container_definitions    = data.template_file.app_container_definitions.rendered # rendered means with populated vars in template
  requires_compatibilities = ["FARGATE"]                                           # serverless version of deploying containers by AWS
  network_mode             = "awsvpc"                                              # we want to use the conatiners within our VPC
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn # runtime role
  task_role_arn            = aws_iam_role.app_iam_role.arn        # startup role

  tags = local.common_tags

}

resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS Service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = aws_vpc.main.id

  egress { # allow outgoing HTTPS for all containers (updating etc.)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # allow outgoin access to MongoDB container
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block,
    ]
  }

  ingress { # allow incoming access to MongoDB from server container
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block,
    ]
  }

  ingress { # Allow incoming access to container port where server is running from load balancer
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "server" {
  name            = "${local.prefix}-server"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.server.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
    ]
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.todo_server.arn
    container_name   = "server"
    container_port   = 3000
  }

}
