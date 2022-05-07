# Create private key
resource "tls_private_key" "splunk-honeypot" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create private key pem file
resource "local_file" "private_key_pem" {
  filename        = "${path.module}/keys/private.pem"
  content         = tls_private_key.splunk-honeypot.private_key_pem
  file_permission = 600
}

# Create public key pem file
resource "local_file" "public_key_pem" {
  filename = "${path.module}/keys/public.pem"
  content  = tls_private_key.splunk-honeypot.public_key_pem
}

# Create public key openssh file
resource "local_file" "public_key_openssh" {
  filename = "${path.module}/keys/id_rsa.pub"
  content  = tls_private_key.splunk-honeypot.public_key_openssh
}
