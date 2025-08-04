terraform {
  cloud {
    organization = "acme-demo-mx"
    workspaces {
      name = "acme-demo-mx-dev"
    }
  }
}
