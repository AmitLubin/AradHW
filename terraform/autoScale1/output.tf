output "private_ips" {
  description = "Private IP addresses of instances in ASG"
  value       = data.aws_instances.asg_instances.private_ips
}