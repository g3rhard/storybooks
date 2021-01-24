terraform {
  backend "gcs" {
    bucket = "disco-beanbag-298417-terraform-g3"
    prefix = "/state/storybooks"
  }
}

output "ip" {
 value = google_compute_instance.instance.network_interface.0.access_config.0.nat_ip
}
