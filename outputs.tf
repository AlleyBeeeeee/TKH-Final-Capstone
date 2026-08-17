output "ec2_public_ip" {
  description = "Public IP address of the deployed web server"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "Web address to access the running site"
  value       = "http://${aws_instance.web_server.public_ip}"
}