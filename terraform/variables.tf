variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-01a00762f46d584a1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "cloudops-lite"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance"
  type        = string
  default     = "0.0.0.0/0"
}
