terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" #US East (N. Virginia)
  profile = "devendra"
  #access_key = "AKIA243T35FGPUF3FROC"
  #secret_key = "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"
}