variable "aws_region" {
  type = string
  default = "eu-north-1" # mumbai region preff (low latency from pune)
  description = "target AWS Region"
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
  description = "Local path to your SSH public key"
}
