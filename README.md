# image-factory

Immutable AMI pipeline for AWS using Packer + Ansible.

## What this repo demonstrates
- AMI builds with Packer (amazon-ebs)
- Configuration and hardening via Ansible roles
- CI validation with GitHub Actions (packer fmt + validate)
- Versioned AMI naming and tagging
- Engineering decisions documented in /docs

## Quick start
Prereqs:
- AWS credentials configured (AWS SSO or env vars)
- Packer installed
- Ansible installed
- An AWS VPC that allows outbound access during build (Packer uses a temporary build instance)

Build:
1. Update variables in `packer/variables.pkr.hcl` if needed
2. Run:
   - `make init`
   - `make validate`
   - `make build`

## Output
A new AMI in your AWS account in the configured region with tags:
- Project = image-factory
- ImageType = base-al2023
- Hardened = true

