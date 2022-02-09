variable "availability_zones" {
  type = list(string)
  description = "AWS Region Availability Zones"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "database_availability_zones" {
  type = list(string)
  description = "AWS Region Availability Zones"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}