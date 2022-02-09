variable "database_availability_zones" {
   type = list(string)
   description = "AWS Region Availability Zones"
}
variable "database_subnet_group_name" {
   type = string
}
variable "aws_security_group_mysql_id" {
   type = string
}