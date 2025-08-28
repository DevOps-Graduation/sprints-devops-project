terraform {
  backend "s3" {
    bucket         = "voting-bucket-580102500712"
    key            = "stage/eks/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
