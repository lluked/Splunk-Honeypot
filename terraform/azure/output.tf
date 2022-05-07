output "instance_ip" {
  description = "The public ip for ssh access"
  value       = azurerm_linux_virtual_machine.splunk-honeypot.public_ip_address
}

output "splunk" {
  description = "The URL to access splunk"
  value       = "https://${azurerm_linux_virtual_machine.splunk-honeypot.public_ip_address}/xyz"
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
  value = "ssh ${var.vm_user}@${azurerm_linux_virtual_machine.splunk-honeypot.public_ip_address} -p ${var.ssh_port} -i ${local_file.private_key_pem.filename}"
}
