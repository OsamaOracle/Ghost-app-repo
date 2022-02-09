output "aws_rds_cluster_mysql_endpoint" {
  value = "${aws_rds_cluster.mysql.endpoint}"
}

output "aws_rds_cluster_mysql_id" {
  value = "${aws_rds_cluster.mysql.id}"
}