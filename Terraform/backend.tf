terraform {
  backend "s3" {
    bucket         = "voting-bucket-sarah-0123"
    key            = "stage/eks/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
