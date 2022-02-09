module "module_vpc" {
  source = "./vpc"
  availability_zones = var.availability_zones
  database_availability_zones = var.database_availability_zones
}
module "module_rds" {
  source = "./rds"
  database_subnet_group_name = "${module.module_vpc.database_subnet_group_name}"
  aws_security_group_mysql_id = "${module.module_vpc.aws_security_group_mysql_id}"
  database_availability_zones = var.database_availability_zones
}
module "module_beanstalk" {
  source = "./beanstalk"
  aws_rds_cluster_mysql_endpoint = "${module.module_rds.aws_rds_cluster_mysql_endpoint}"
  aws_vpc_main_id = "${module.module_vpc.aws_vpc_main_id }"
  aws_subnet_public_subnet_ids = module.module_vpc.aws_subnet_public_subnet_ids
  aws_security_group_application_id = "${module.module_vpc.aws_security_group_application_id}"
}
module "module_autoscaling" {
  source = "./autoscaling"
  aws_rds_cluster_mysql_id = "${module.module_rds.aws_rds_cluster_mysql_id}"
}
module "module_lambda" {
  source = "./lambda"
  aws_security_group_application_id = "${module.module_vpc.aws_security_group_application_id}"
  aws_subnet_public_subnet_ids = "${module.module_vpc.aws_subnet_public_subnet_ids}"
  aws_rds_cluster_mysql_endpoint = "${module.module_rds.aws_rds_cluster_mysql_endpoint}"
}