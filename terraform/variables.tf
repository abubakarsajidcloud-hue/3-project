variable "instance_type" {
  default = "t2.micro"
}

variable "project_name" {
  default = "cloudops-lite"
}

variable "environment" {
  default = "production"
}

variable "allowed_ssh_cidr" {
  default = "0.0.0.0/0"
}