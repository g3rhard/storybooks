provider "cloudflare" {
  version = "~> 2.0"
  token   = var.cloudflare_api_token
}

# Zone

# DNS A record
