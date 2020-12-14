provider "google" {
  credentials = file("terraform-sa-key.json")
  project     = "disco-beanbag-298417"
  region      = "us-central1"
  zone        = "us-central1-c"
  version     = "~> 3.38"
}

# IP ADDRESS

# NETWORK

# FIREWALL RULE

# OS IMAGE

# COMPUTE ENGINE INSTANCE
