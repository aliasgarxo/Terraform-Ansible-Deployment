output "alb_dns_name" {
    value = "DNS name of the Applicaton Load Balancer ${aws_lb.front_end.dns_name}"
}