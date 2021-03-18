output "bastion_host" {
  value = aws_instance.bastion.public_dns
}

output "app_endpoint" {
  value = aws_lb.todo_server.dns_name
}
