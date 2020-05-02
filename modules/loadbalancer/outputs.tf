output "load_balancer" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb.application
}

# output "http_target_arn" {
#   description = "The ID and ARN of the https target group."
#   value       = aws_lb_target_group.http_target_group
# }
#
# output "https_target_arn" {
#   description = "The ID and ARN of the https target group."
#   value       = aws_lb_target_group.https_target_group
# }
