output "alb_dns_name" {
  description = "DNS publico del Application Load Balancer."
  value       = aws_lb.main.dns_name
}