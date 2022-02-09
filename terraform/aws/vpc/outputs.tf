output "database_subnet_group_name" {
  value = "${aws_db_subnet_group.database_subnet_group.name}"
}

output "aws_vpc_main_id" {
  value = "${aws_vpc.main.id}"
}

output "aws_subnet_public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

output "aws_security_group_mysql_id" {
  value = "${aws_security_group.mysql.id}"
}

output "aws_security_group_application_id" {
  value = "${aws_security_group.application.id}"
}
