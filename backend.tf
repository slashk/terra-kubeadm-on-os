terraform {
  backend "s3" {
    bucket = "tf.pepple.info"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
