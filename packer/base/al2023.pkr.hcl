packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  timestamp = formatdate("YYYYMMDD-HHmm", timestamp())
  ami_name  = "${var.ami_name_prefix}-${local.timestamp}"
}

source "amazon-ebs" "al2023" {
  region        = var.aws_region
  instance_type = var.instance_type
  ssh_username  = var.ssh_username

  ami_name      = local.ami_name

  tags = merge(var.tags, {
    BuildTimestamp = local.timestamp
    Source         = "packer"
  })

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  subnet_id = var.subnet_id != "" ? var.subnet_id : null
  vpc_id    = var.vpc_id != "" ? var.vpc_id : null

  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null
}

build {
  name    = "base-al2023"
  sources = ["source.amazon-ebs.al2023"]

  provisioner "shell" {
    script = "scripts/bootstrap.sh"
  }

  provisioner "ansible" {
    playbook_file = "ansible/playbooks/harden.yml"
    extra_arguments = [
      "-e", "ansible_python_interpreter=/usr/bin/python3"
    ]
  }

  post-processor "manifest" {
    output = "packer-manifest.json"
  }
}
