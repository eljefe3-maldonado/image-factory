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

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_name_prefix" {
  type    = string
  default = "image-factory-ubuntu22"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Optional subnet for the temporary build instance."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Optional VPC for the temporary build instance."
}

variable "iam_instance_profile" {
  type        = string
  default     = ""
  description = "Optional instance profile for the temporary build instance."
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "image-factory"
    ImageType = "ubuntu22-cis"
    Hardened  = "true"
  }
}

locals {
  build_ts = formatdate("YYYYMMDD-HHmm", timestamp())
  ami_name = "${var.ami_name_prefix}-${local.build_ts}"
}

source "amazon-ebs" "ubuntu22" {
  region        = var.aws_region
  instance_type = var.instance_type
  ssh_username  = "ubuntu"

  ami_name = local.ami_name

  tags = merge(var.tags, {
    BuildTimestamp = local.build_ts
    Source         = "packer"
  })

  # Canonical Ubuntu owner ID commonly used for public Ubuntu AMIs
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  subnet_id = var.subnet_id != "" ? var.subnet_id : null
  vpc_id    = var.vpc_id != "" ? var.vpc_id : null

  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null
}

build {
  name    = "ubuntu22-cis"
  sources = ["source.amazon-ebs.ubuntu22"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 python3-pip curl",
      "sudo bash -lc 'chmod +x /tmp/install-goss.sh /tmp/run-goss.sh || true'"
    ]
  }

  # Upload goss assets
  provisioner "file" {
    source      = "goss/goss.yaml"
    destination = "/tmp/goss.yaml"
  }

  provisioner "file" {
    source      = "scripts/install-goss.sh"
    destination = "/tmp/install-goss.sh"
  }

  provisioner "file" {
    source      = "scripts/run-goss.sh"
    destination = "/tmp/run-goss.sh"
  }

  # Install goss
  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/install-goss.sh /tmp/run-goss.sh",
      "sudo /tmp/install-goss.sh"
    ]
  }

  # Run Ansible hardening
  provisioner "ansible" {
    playbook_file = "ansible/playbooks/harden-ubuntu.yml"

    # Ensure Ansible finds Galaxy roles installed into ansible/roles
    extra_arguments = [
      "--roles-path=ansible/roles",
      "-e", "ansible_python_interpreter=/usr/bin/python3"
    ]
  }

  # Validate with goss after hardening
  provisioner "shell" {
    inline = [
      "sudo /tmp/run-goss.sh"
    ]
  }

  post-processor "manifest" {
    output = "packer-manifest-ubuntu22.json"
  }
}
