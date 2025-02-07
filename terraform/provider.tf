provider "aws" {

  region  = "eu-north-1"
  profile = "my"

  default_tags {
    tags = {
      app   = "send-mail"
      scope = "2025-02"
    }
  }
}

