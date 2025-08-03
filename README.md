# Demo: ACME Cloud 2.0

This repository contains Terraform configurations for deploying AWS infrastructure, including networking and compute resources. It also includes a Sentinel policy to ensure compliance with allowed EC2 instance types.

---
## Table of Contents

- [Demo: ACME Cloud 2.0](#demo-acme-cloud-20)
  - [Table of Contents](#table-of-contents)
  - [Project Overview](#project-overview)
  - [📁 Directory Structure](#-directory-structure)
  - [⚙️ Pre-Requisites](#️-pre-requisites)
  - [🔐 HCP Terraform Setup](#-hcp-terraform-setup)
  - [Configuration](#configuration)
    - [banckend.tf](#banckendtf)
    - [main.tf](#maintf)
    - [variables.tf](#variablestf)
    - [outputs.tf](#outputstf)
  - [🧠 Sentinel Policy](#-sentinel-policy)
  - [🧱 Standardized Module Usage](#-standardized-module-usage)
    - [Networking Module (`/acme-networking`)](#networking-module-acme-networking)
      - [Usage](#usage)
      - [Outputs](#outputs)
    - [Compute Module (`/acme-compute`)](#compute-module-acme-compute)
      - [Usage](#usage-1)
      - [Input Variables](#input-variables)
      - [Outputs](#outputs-1)
  - [Usage](#usage-2)

---
## Project Overview

This project demonstrates how to use **HCP Terraform** to provision a simple **AWS EC2 instance** using:

- ✅ Reusable Terraform modules (networking and compute) for standardization
- ✅ Workspace organization with environment variables for AWS credentials and other terraform variables
  ✅ GitOps-style workflow with VCS integration
- ✅ Sentinel policy that validates EC2 instance types against a predefined list of allowed types during Terraform plan/apply
  
This project aims to provision a basic AWS environment with the following components:

* **Networking:** A Virtual Private Cloud (VPC) and a subnet.
* **Compute:** An EC2 instance deployed within the created network.

---
## 📁 Directory Structure
```
acme-demo/
├── README.md
├── backend.tf
├── main.tf
├── outputs.tf
└── variables.tf

```
---
## ⚙️ Pre-Requisites

- AWS account with IAM access
- HCP Terraform account
- GitHub (or other VCS provider) repo with this code
- Terraform CLI (optional for local testing)

---
## 🔐 HCP Terraform Setup

1. **Create a new Workspace** in HCP Terraform using VCS integration
2. Set the following environment variables:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Commit and push your code — this will trigger a `terraform plan`

---
## Configuration

### banckend.tf

This project is configured for HCP Terraform integration via the `backend.tf` file:

```
terraform {
  cloud {
    organization = "mx-acme-demo"
    workspaces {
      name = "mx-acme-demo-dev"
    }
  }
}
```
This configuration directs Terraform to use HCP Terraform for state management and remote operations. The Sentinel policy will automatically be evaluated as part of your HCP Terraform workflow.

### main.tf

The project uses variables to allow for flexible deployments across different environments.

* **`main.tf`**: The main Terraform configuration file.

  * `provider "aws"`: Configures the AWS provider, currently set to `us-east-1` region.

  * `module "acme-networking"`: Deploys the VPC and subnet.

  * `module "acme-compute"`: Deploys the EC2 instance. Pay attention to the `instance_type` variable here, as it's subject to the Sentinel policy.

### variables.tf

* **`variables.tf`**: Defines the input variables for the project. The default values of these variables can be override by HCP Terraform Organization or Workspace variables.

  * `project`: The name of the project (e.g., `acme-demo`).
  * `environment`: The deployment environment (e.g., `dev`, `staging`, `prod`).
  * `prefix`: A prefix for resource naming to ensure uniqueness.

### outputs.tf

* **`outputs.tf`**: Defines the output values that will be displayed after a successful `terraform apply`:

  * `instance_id`: The ID of the provisioned EC2 instance.

---
## 🧠 Sentinel Policy

The `ec2-instance_type-check` is configured directly in HCP Terraform and is designed to enforce allowed EC2 instance types.

* **`allowed_types`**: This variable within the policy defines the list of EC2 instance types that are permitted (currently `["t3.micro", "t2.micro"]`).

* The policy checks all `aws_instance` resources that are being created or updated in the Terraform plan.

* If any instance's `instance_type` is not in the `allowed_types` list, the policy will fail, preventing the deployment.

---
## 🧱 Standardized Module Usage

This project uses private modules to enforce consistent provisioning. Modules can be reused across environments or teams by simply changing input variables. These are hosted on an organization's private registry and are only available to members of this organization.

### Networking Module (`/acme-networking`)

This module is responsible for provisioning the core networking components in AWS.

#### Usage

```
module "acme-networking" {
  source  = "app.terraform.io/mx-acme-demo/acme-networking/aws"
  version = "1.0.0"
  # insert INPUT variables here
}
```

* #### Input Variables

* `vpc_cidr` (string): The CIDR block for the Virtual Private Cloud (VPC).

* `subnet_cidr` (string): The CIDR block for the public subnet within the VPC.

* `availability_zone` (string): The AWS Availability Zone where the subnet will be created.

* `name_prefix` (string): A prefix used for naming the created VPC and subnet resources. Suggestion: "${var.prefix}-${var.project}-${var.environment}".

#### Outputs

* `vpc_id`: The ID of the created VPC.

* `subnet_id`: The ID of the created public subnet.

### Compute Module (`/acme-compute`)

This module is responsible for provisioning an EC2 instance and its associated security group.

#### Usage

```
module "acme-compute" {
  source  = "app.terraform.io/mx-acme-demo/acme-compute/aws"
  version = "1.0.0"
  # insert INPUT variables here
}
```

#### Input Variables

* `ami_id` (string): The AMI ID for the EC2 instance.

* `instance_type` (string): The instance type for the EC2 instance. This is subject to the Sentinel policy.

* `subnet_id` (string): The ID of the subnet where the EC2 instance will be launched.

* `vpc_id` (string): The ID of the VPC where the security group will be created.

* `name_prefix` (string): A prefix used for naming the created EC2 instance and security group. Suggestion: "${var.prefix}-${var.project}-${var.environment}".

* `allowed_ports` (list(string), optional): A list of inbound TCP ports to allow on the security group (defaults to `["80", "443"]`).

* `allowed_ssh_cidrs` (string, optional): The CIDR block from which SSH access is allowed (defaults to `"0.0.0.0/0"`).

#### Outputs

* `instance_id`: The ID of the created EC2 instance.

---
## Usage

This project is configured to work with [HCP Terraform](https://cloud.hashicorp.com/). Once your repository is connected to an HCP Terraform workspace, the deployment process is automated:

1. **Push Code Changes:** Simply commit and push changes to your connected Git repository.

2. **Automatic Plan:** HCP Terraform will automatically detect the code changes and initiate a Terraform plan. This plan will show you what resources Terraform intends to create, modify, or destroy. The Sentinel policy will be evaluated during this phase.

3. **Apply Confirmation (if required):** Depending on your workspace's settings (e.g., "Auto Apply" or "Manual Apply"), you may need to manually confirm the apply operation within the HCP Terraform UI. If "Auto Apply" is enabled, the changes will be applied automatically after a successful plan and policy evaluation.

Monitor the progress and review the details of each run directly in your HCP Terraform workspace.