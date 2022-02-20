terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "state-location-bucket"
    key    = "global/s3/terraform.tfstate"
    region = ""
    # Replace this with your DynamoDB table name!
    dynamodb_table = "state-location-bucket"
    encrypt        = true
  }
}


#terraform {
#  backend "consul" {
#    address  = "consul.example.com:8500"
#    scheme   = "http"
#    path     = "tf/terraform.tfstate"
#    lock     = true
#    gzip     = false
#  }
#}