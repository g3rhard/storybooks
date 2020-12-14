terraform {
  backend "gcs" {
    bucket = "disco-beanbag-298417-terraform-g3"
    prefix = "/state/storybooks"
  }
}
