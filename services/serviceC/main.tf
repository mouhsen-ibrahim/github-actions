terraform {
  required_version = "1.13.1"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_string" "sample" {
  length  = 30
  upper   = true
  lower   = true
  numeric = true
  special = false
}

output "random_string_value" {
  description = "The generated random string"
  value       = random_string.sample.result
}
