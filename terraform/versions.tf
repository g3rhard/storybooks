terraform {
  required_providers {
    mongodbatlas = {
      source = "terraform-providers/mongodbatlas"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 0.13"
}
