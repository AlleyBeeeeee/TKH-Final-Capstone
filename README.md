cat << 'EOF' > README.md

# Automated DevSecOps Cloud Architecture & IaC Quality Gate

![DevSecOps Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=github-actions)
![Security Scanner](https://img.shields.io/badge/SAST-tfsec%20Passed-brightgreen?logo=aquasec)
![IaC](https://img.shields.io/badge/IaC-Terraform%20v1.7+-purple?logo=terraform)
![Cloud](https://img.shields.io/badge/Cloud-AWS-orange?logo=amazon-aws)
![Zero Trust](https://img.shields.io/badge/Port%2022-Restricted-success)

> _"Friends don't let friends deploy insecure infrastructure to production."_

## Project Overview

This repository delivers an automated, enterprise-grade cloud environment on Amazon Web Services (AWS) using Infrastructure as Code (IaC) and DevSecOps continuous integration.

Instead of manual "ClickOps" in the AWS Console, every infrastructure change is validated through an automated CI/CD security gate. If someone tries to commit insecure Terraform code (like opening SSH to `0.0.0.0/0` or leaving S3 buckets public), **tfsec immediately breaks the build** before the code can touch AWS.

---

## Architecture Blueprint

```text
[ Developer: git push ]
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│              GitHub Actions CI/CD Pipeline              │
│  ├── 1. Format Check (terraform fmt -check)             │
│  ├── 2. Config Validation (terraform validate)          │
│  └── 3. Static Security Gate (tfsec SAST Scanner)       │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼ (Passed Gate / Green Check)
┌─────────────────────────────────────────────────────────┐
│            AWS Production (us-east-1 Region)            │
│                                                         │
│  Custom Production VPC (10.0.0.0/16)                    │
│    ├── Internet Gateway (IGW) & Public Route Table      │
│    └── Public Subnet (10.0.1.0/24)                      │
│          │                                              │
│          ├── Stateful Security Group                    │
│          │     ├── Inbound: TCP/80 (HTTP Gateway)       │
│          │     └── SSH (Port 22): Hardened / Restricted │
│          │                                              │
│          └── EC2 Web Server (Amazon Linux 2023)         │
│                └── Automated user_data (Apache / HTTPD) │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Key Security Controls & DevSecOps Philosophy

- **Shift-Left Static Analysis:** Security starts in the IDE, not after a breach. Integrated `tfsec` within GitHub Actions to scan Terraform code on every commit.
- **Perimeter Hardening:** Completely eliminated unrestricted remote administrative access (`0.0.0.0/0` on Port 22 / SSH). No brute-force vectors permitted on our watch.
- **Network Isolation:** Built an isolated, custom-engineered VPC with dedicated route tables instead of relying on the default AWS network.
- **Zero-Touch Bootstrapping:** EC2 instances are treated as _cattle, not pets_. The server automatically provisions and starts Apache on launch via `user_data` without requiring manual SSH logins.

## Repository Structure

- `.github/workflows/devsecops-pipeline.yml` — The automated CI/CD quality gate running linting and `tfsec` SAST.
- `main.tf` — Core architectural blueprint (VPC, Subnet, Route Table, Security Group, EC2).
- `variables.tf` — Modular environment variables (region, CIDR ranges, instance sizing).
- `outputs.tf` — Clean terminal exports (Public IP & live URL).
- `.gitignore` — Defense against accidental `.tfstate` and sensitive credential leakage.
- `README.md` — The front door to this architecture.

---

## Quickstart & Verification

### Prerequisites

- Terraform CLI (`>= 1.0.0`)
- AWS CLI authenticated with appropriate IAM credentials
- Git

### Deployment Steps

```bash
# 1. Initialize backend & download AWS provider plugins
terraform init

# 2. Verify HCL syntax and configuration integrity
terraform validate

# 3. Provision the live cloud infrastructure
terraform apply -auto-approve

# 4. Access Webserver
http://<ec2_public_ip>

#5. Clean Up /Tearndown
terraform destroy -auto-approve
```

---

## Author

**Alexandra Blandon** — _Cloud Security & DevSecOps Engineer_
