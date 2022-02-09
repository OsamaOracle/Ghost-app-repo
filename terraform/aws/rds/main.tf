####################################################################################################
# Secret database master credentials
####################################################################################################
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "db_credentials"
}

locals {
  db_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.db_credentials.secret_string
  )
}

####################################################################################################
# Aurora database
####################################################################################################
resource "aws_rds_cluster" "mysql" {
  cluster_identifier          = "ghost-database"
  deletion_protection         = true
  skip_final_snapshot         = true
  availability_zones          = var.database_availability_zones
  database_name               = "ghost"
  master_username             = local.db_credentials.username
  master_password             = local.db_credentials.password
  db_subnet_group_name        = var.database_subnet_group_name
  vpc_security_group_ids      = [tostring(var.aws_security_group_mysql_id)]
  engine                      = "aurora-mysql"
  engine_version              = "5.7.mysql_aurora.2.07.2"
  enabled_cloudwatch_logs_exports = ["general"]
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "ghost-database-${count.index}"
  cluster_identifier = aws_rds_cluster.mysql.id
  instance_class     = "db.r5.large"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.07.2"
}