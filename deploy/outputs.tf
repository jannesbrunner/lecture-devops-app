## Database Outputs

output "db_host_cluster" {
  value = aws_docdb_cluster.main.endpoint
}

output "db_host_zone_a" {
  value = aws_docdb_cluster_instance.db_zone_a.endpoint
}

output "db_port_zone_a" {
  value = aws_docdb_cluster_instance.db_zone_a.port
}

output "db_host_zone_b" {
  value = aws_docdb_cluster_instance.db_zone_b.endpoint
}

output "db_port_zone_b" {
  value = aws_docdb_cluster_instance.db_zone_b.port
}
