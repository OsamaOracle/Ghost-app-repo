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
# Beanstalk application
####################################################################################################
resource "aws_elastic_beanstalk_application" "application" {
  name        = "ghost-application"
}

resource "aws_elastic_beanstalk_application_version" "version" {
  name        = "ghost-application-version"
  application = aws_elastic_beanstalk_application.application.name
  bucket      = "ghost-website-beanstalk"
  key         = "ghost-app.zip"
}

####################################################################################################
# Beanstalk environment
####################################################################################################
resource "aws_elastic_beanstalk_environment" "environment" {
  name                = "ghost-beanstalk-environment"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.10 running Node.js 12"

  # Server EC2
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  #setting {
  #  namespace = "aws:autoscaling:launchconfiguration"
  #  name      = "InstanceType"
  #  value     = "t2.large"
  #}
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.aws_vpc_main_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", sort(var.aws_subnet_public_subnet_ids))
  }

  # Logs
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = true
  }

  # Autoscaling
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }
  
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  # Environment variables
  setting {
    name      = "NODE_ENV"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "production"
  }
  setting {
    name      = "database__connection__user"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = local.db_credentials.username
  }
  setting {
    name      = "database__connection__password"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = local.db_credentials.password
  }

  setting {
    name      = "database__connection__host"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = var.aws_rds_cluster_mysql_endpoint
  }
}