# Decisions

## Why immutable images
Immutable images reduce configuration drift and make deployments predictable.

## Why Ansible inside Packer
Ansible provides readable and reusable configuration logic.
The same roles can later be reused for configuration enforcement outside image builds if needed.

## Why compliance frameworks are not front and center
This repo focuses on engineering artifacts and operational ownership.
Compliance alignment is treated as a downstream outcome supported by build controls, tagging, and validation.
