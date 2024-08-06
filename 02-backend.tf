# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "barney-terraform-remote-state"
    key            = "petclinic-eks/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "petclinic-eks-terraform-state-lock"
  }
}

