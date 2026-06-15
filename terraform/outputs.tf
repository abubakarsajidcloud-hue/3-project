# -------------------------------------------------------
# Outputs
# -------------------------------------------------------

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Elastic IP address of the web server"
  value       = aws_eip.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "vpc_id" {
  description = "Default VPC ID being used"
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "Subnet ID used for the EC2 instance"
  value       = tolist(data.aws_subnets.default.ids)[0]
}

output "security_group_id" {
  description = "Web server security group ID"
  value       = aws_security_group.web_sg.id
}

output "s3_backup_bucket" {
  description = "S3 bucket name for backups"
  value       = aws_s3_bucket.backups.id
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "iam_instance_profile" {
  description = "IAM instance profile name attached to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}


