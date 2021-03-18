resource "aws_lb" "todo_server" {
  name               = "${local.prefix}-main"
  load_balancer_type = "application" # handle requests at HTTP level
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  security_groups = [aws_security_group.lb.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "todo_server" {
  name        = "${local.prefix}-server"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 3000

  health_check {
    path = "/"
  }
  # to this health check on this path and if result in non satisfying status code
  # tell ECS service to restart task and fallback to another AZ
}

resource "aws_lb_listener" "todo_server" { # listening here and forward
  load_balancer_arn = aws_lb.todo_server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_server.arn
  }
}

resource "aws_security_group" "lb" {
  description = "Allow access to Application Load Balancer"
  name        = "${local.prefix}-lb"
  vpc_id      = aws_vpc.main.id

  ingress { # public internet into load balancer
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # load balancer to application
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags

}
