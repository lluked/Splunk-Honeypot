resource "aws_vpc" "splunk-honeypot" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.vpc_instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Splunk-Honeypot VPC"
    }
}

resource "aws_subnet" "splunk-honeypot" {
  vpc_id                  = aws_vpc.splunk-honeypot.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "Splunk-Honeypot Subnet"
  }
}

resource "aws_route_table" "splunk-honeypot" {
  vpc_id = aws_vpc.splunk-honeypot.id

  tags = {
    Name = "Splunk-Honeypot Route Table"
  }
}

resource "aws_route_table_association" "splunk-honeypot" {
  subnet_id      = aws_subnet.splunk-honeypot.id
  route_table_id = aws_route_table.splunk-honeypot.id
}

resource "aws_internet_gateway" "splunk-honeypot" {
  vpc_id = aws_vpc.splunk-honeypot.id

  tags = {
    Name = "Splunk-Honeypot Internet Gateway"
  }
}

resource "aws_route" "splunk-honeypot" {
  route_table_id         = aws_route_table.splunk-honeypot.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.splunk-honeypot.id
}

resource "aws_network_acl" "splunk-honeypot" {
  vpc_id = aws_vpc.splunk-honeypot.id
  subnet_ids = [ aws_subnet.splunk-honeypot.id ]

  ingress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }
  
  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }
  
  tags = {
    Name = "Splunk-Honeypot Network ACL"
  }
}

resource "aws_security_group" "splunk-honeypot" {
  name        = "Splunk-Honeypot"
  description = "Splunk-Honeypot Security Group"
  vpc_id      = aws_vpc.splunk-honeypot.id

  ingress {
    description = "Cowrie - SSH"
    from_port   = var.cowrie_ssh_port
    to_port     = var.cowrie_ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Cowrie - Telnet"
    from_port   = var.cowrie_telnet_port
    to_port     = var.cowrie_telnet_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web - HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    description = "Web - HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    description = "Admin - SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Splunk-Honeypot Security Group"
  }
}

resource "aws_key_pair" "splunk-honeypot" {
  key_name   = "Splunk-Honeypot"
  public_key = tls_private_key.splunk-honeypot.public_key_openssh
}

resource "aws_instance" "splunk-honeypot" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_instance_type
  key_name                    = aws_key_pair.splunk-honeypot.key_name
  subnet_id                   = aws_subnet.splunk-honeypot.id
  vpc_security_group_ids      = [aws_security_group.splunk-honeypot.id]
  user_data_base64            = data.template_cloudinit_config.config.rendered
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  # remote-exec to delay local-exec until instance is ready
  provisioner "remote-exec" {
    inline = ["echo remote-exec > terraform.txt"]
    connection {
      host        = aws_instance.splunk-honeypot.public_ip
      type        = "ssh"
      user        = var.vm_user
      private_key = tls_private_key.splunk-honeypot.private_key_pem
    }
  }

  # Provision Ansible Playbooks
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=\"False\" ansible-playbook -u ${var.vm_user} -i '${aws_instance.splunk-honeypot.public_ip},' --private-key \"./keys/private.pem\" --extra-vars '{\"traefik_tls\":true}' --extra-vars 'traefik_splunk_proxy_password=${var.traefik_splunk_proxy_password} splunk_password=${var.splunk_password} cowrie_ssh_port=${var.cowrie_ssh_port} cowrie_telnet_port=${var.cowrie_telnet_port} ssh_port=${var.ssh_port}' ../../ansible/main.yml"
  }

  # Restart instance after provisioning
  provisioner "local-exec" {
    command = "ssh -tt -o StrictHostKeyChecking=no ${var.vm_user}@${aws_instance.splunk-honeypot.public_ip} -i ./keys/private.pem sudo 'shutdown -r'"
  }

  tags = {
    Name = "Splunk-Honeypot"
  }
}
