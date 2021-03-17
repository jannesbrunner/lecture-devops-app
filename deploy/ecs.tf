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
