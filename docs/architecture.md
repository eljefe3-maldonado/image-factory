# Architecture

Packer builds an AMI in AWS using a temporary EC2 instance.
Ansible configures the instance during build time.
The build produces a versioned AMI and writes a manifest file.

Core properties:
- Immutable output: AMI is the artifact
- Repeatable: build is deterministic within defined inputs
- Traceable: tags and manifest provide provenance
