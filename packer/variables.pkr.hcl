variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "image-factory-al2023"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

variable "subnet_id" {
  type    = string
  default = ""
  description = "Optional. If empty, Packer will use default VPC subnet behavior."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Optional. Useful if you restrict builds to a specific VPC."
}

variable "iam_instance_profile" {
  type        = string
  default     = ""
  description = "Optional. Instance profile name for the temporary build instance."
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "image-factory"
    Owner     = "Wilberto Maldonado"
    ImageType = "base-al2023"
    Hardened  = "true"
  }
}
