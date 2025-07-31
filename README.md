# ACME-demo

This project demonstrates how to use **HCP Terraform** to provision a simple **AWS EC2 instance** using:

- ✅ Reusable Terraform modules (networking and compute)
- ✅ GitOps-style workflow with VCS integration
- ✅ Sentinel policy to block public SSH access on port 22
- ✅ Workspace environment variables for AWS credentials
- ✅ Standardization through modules

---

## 📁 Project Structure

hcp-terraform-demo/
├── main.tf # Root Terraform configuration
├── outputs.tf # Outputs
├── modules/
│ ├── networking/ # Reusable VPC + Subnet module
│ └── compute/ # Reusable EC2 + SG module
└── sentinel/
└── restrict_ssh.sentinel # Policy to block port 22 open to 0.0.0.0/0

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

## 🧠 Sentinel Policy

The included policy (`sentinel/restrict_ssh.sentinel`) **blocks any Security Group rule** that opens **port 22 (SSH)** to the public internet:

```python
rule.from_port == 22 and
rule.to_port == 22 and
rule.cidr_blocks contains "0.0.0.0/0"

This ensures no insecure public access is accidentally provisioned.

To pass the policy, restrict SSH to a private IP range like:
allowed_ssh_cidrs = ["10.0.0.0/16"]

🧱 Standardized Module Usage
This project uses modules to enforce consistent provisioning:

Networking Module

VPC and Public Subnet with map_public_ip_on_launch

Compute Module

Security Group and EC2 instance with parameterized inputs

Modules can be reused across environments or teams by simply changing input variables.

✅ Example Run
terraform init
terraform plan
terraform apply

Or commit a change and let HCP Terraform handle the plan + apply through the UI and/or CLI.

📌 Notes
The AMI ID used is for Amazon Linux 2 in us-east-1. Adjust it for other regions.

Sentinel policy must be assigned to the workspace or a policy set in HCP.

Use tags or naming conventions inside modules to align with enterprise standards.

🧩 Possible Extensions
Add a staging and prod workspace to show environment separation

Include Run Tasks (e.g., checkov or tfsec)

Use Terraform Cloud registry modules instead of local ones

---

Let me know if you want the same README with your branding or presentation tips added for live demos.
