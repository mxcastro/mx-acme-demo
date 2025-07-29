terraform { 
    cloud {
        organization = "mx-acme-demo"
        workspaces{
            name = "mx-acme-demo-dev"
        }
    }
}
