variable "aws_rds_cluster_mysql_endpoint" {
   type = string
}

variable "aws_security_group_application_id" {
   type = string
}

variable "aws_vpc_main_id" {
   type = string
}

variable "aws_subnet_public_subnet_ids" {
   type = list(string)
}