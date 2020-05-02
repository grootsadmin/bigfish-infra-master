output "jumpserver_sg" {
  value = aws_security_group.jumpserver
}

output "app_sg" {
  value = aws_security_group.app
}

output "web_sg" {
  value = aws_security_group.web
}

output "notification_sg" {
  value = aws_security_group.notification
}

output "job_sg" {
  value = aws_security_group.job
}

output "captcha_sg" {
  value = aws_security_group.captcha
}

output "rds_sg" {
  value = aws_security_group.rds
}

output "lb_sg" {
  value = aws_security_group.lb
}
