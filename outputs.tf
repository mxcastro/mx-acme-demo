output "order-web-url" {
  value = "http://${aws_eip.order_web.public_dns}:8001"
}

output "order-web-ip" {
  value = "http://${aws_eip.order_web.public_ip}:8001"
}