terraform {
  backend "remote" {
    organization = "your-org-name"
    workspaces {
      name = "platform-infra-dev"
    }
  }
} 