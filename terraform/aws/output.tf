output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.splunk-honeypot.public_ip
}

output "splunk" {
  description = "The URL to access splunk"
  value       = "https://${aws_instance.splunk-honeypot.public_ip}/xyz"
}

output "ssh_port" {
  value = var.ssh_port
}

output "ssh_user" {
  value = var.vm_user
}

output "ssh_private_key" {
  value = local_file.private_key_pem.filename
}

output "ssh" {
  value = "ssh ${var.vm_user}@${aws_instance.splunk-honeypot.public_ip} -p ${var.ssh_port} -i ${local_file.private_key_pem.filename}"
}
