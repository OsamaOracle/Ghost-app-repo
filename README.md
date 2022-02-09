# Ghost application

## Directory

- `.github/` contains the workflow execute by github actions to deploy the application
- `src` contains the code source for the application ghost.org
- `terraforn` contains the infrastructure as a code

## Setup

To start working with the application you must to setup aws, terraform and github.

### AWS
- Create an AWS account
- Create a new secret in secret manager to store the database information. You must to name it `db_credentials` and it must to contains to key, `username` and `password`
- Create an AWS IAM user for github with the AdministratorAccess and keep the aws key and aws secret for later
- Create an AWS IAM user for terraform with the AdministratorAccess and keep the aws key and aws secret for later
- Create an AWS IAM role `aws-elasticbeanstalk-ec2-role` with the policy `AmazonEC2FullAccess` and `CloudWatchFullAccess`
- Create the bucket `ghost-application-beanstalk` with default configuration

### Terraform
- Create a terraform account (https://cloud.hashicorp.com/products/terraform)
- Create a token and keep it for later
- Create an organisation and a workspace on it
- On the workspace add 2 variables, `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` with the value from the AWS IAM user for terraform created previously
- Edit `terraform/main.tf` with your information

```
  cloud {
    organization = "my_organization"

    workspaces {
      name = "my_workspace"
    }
  }
```

### Github
In the project repertory, create secrets in the settings
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from the AWS IAM user created previously
- `TERRAFORM_TOKEN` created in terraform.
- `AWS_S3_BUCKET` with value `ghost-application-beanstalk`
- `AWS_S3_KEY` with value `ghost-app.zip`

## To deploy
After each github main branch update, github actions will deploy the application.
The first time you are deploying, the ghost url will be created on aws beanstalk. It must to be set on ghost configuration to work properly `src/core/shared/config/env/config.production,json` and redeploy.
To delete all the posts, open the aws lambda service and execute the function delete_all_posts.

## Logs
On cloudwatch, you will find all the applications logs split between each type (nginx, beanstalk, web)
```
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/eb-engine.log
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/eb-hooks.log
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/httpd/access_log
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/httpd/error_log
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/nginx/access.log
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/nginx/error.log
/aws/elasticbeanstalk/ghost-beanstalk-environment/var/log/web.stdout.log
```

## Information
The infrastucture will scale between 1 and 5 servers depending of the cpu usage. Terraform beanstalk can be update to add more servers if necessary.

You can deploy on another region by adding a new provider on `terraform/main.tf` exemple :
```
provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

module "eu-west-1" {
  source = "./aws"
  name   = "eu-west-1"
  providers = {
    aws = "aws.eu-west-1"
  }
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  database_availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
```

And you can create a new module for GCP or azure if you want to deploy on multi cloud services.