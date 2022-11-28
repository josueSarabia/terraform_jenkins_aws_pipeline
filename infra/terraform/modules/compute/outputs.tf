output "web_server_name_tag" {
  description = "The Name tag of the web server"
  value = aws_instance.web_server[0].tags_all["Name"]
}

output "web_servers_info" {
  value = aws_instance.web_server[*]
}