# Build flow

1. Packer selects latest Amazon Linux 2023 source AMI
2. Packer launches a temporary build instance
3. bootstrap.sh updates packages and ensures python3 exists
4. Ansible runs baseline hardening role
5. Packer creates a new AMI from the instance
6. Packer writes packer-manifest.json
