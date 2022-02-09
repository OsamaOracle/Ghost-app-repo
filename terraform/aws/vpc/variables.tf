variable "availability_zones" {
  type = list(string)
  description = "AWS Region Availability Zones"
}
variable "database_availability_zones" {
  type = list(string)
  description = "AWS Region Availability Zones"
}
variable "vpc_cidr_block" {
  type = string
  description = "Main VPC CIDR Block"
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr_block" {
  type = list(string)
  description = "Public Subnet CIDR Block"
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "database_subnet_cidr_block" {
  type = list(string)
  description = "Database Subnet CIDR Block"
  default  = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}

