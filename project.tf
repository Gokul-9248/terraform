#creating_a_vpc

resource "aws_vpc" "gokul_vpc" {
  cidr_block = "10.0.0.0/16"
}

#aws_internet_gateway_creation

resource "aws_internet_gateway" "gokul_igw" {
  vpc_id = aws_vpc.gokul_vpc.id

  tags = {
    Name = "gateway"
  }
}

#setting_up_the_route_table

resource "aws_route_table" "gokul_route_table" {
  vpc_id = aws_vpc.gokul_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gokul_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gokul_igw.id
  }

  tags = {
    Name = "gokul_route"
  }
}

#settingup_subnet

resource "aws_subnet" "gokul_subnet" {
  vpc_id            = aws_vpc.gokul_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "gokul_subnet"
  }
}

#Associate_subnet_with_route_table

resource "aws_route_table_association" "gokul_subnet_association" {
  subnet_id      = aws_subnet.gokul_subnet.id
  route_table_id = aws_route_table.gokul_route_table.id
}

#creating_security_group

resource "aws_security_group" "gokul_security_group" {
  vpc_id = aws_vpc.gokul_vpc.id

   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creating_network_interface

resource "aws_network_interface" "gokul_network_interface" {
  subnet_id       = aws_subnet.gokul_subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.gokul_security_group.id]
}

#attaching_a_elasticIP

resource "aws_eip" "gokul_eip" {
  domain             = "vpc"
  network_interface = aws_network_interface.gokul_network_interface.id
  instance          = aws_instance.gokul_ec2_instance.id
  associate_with_private_ip = "10.0.1.10"
}


#Creating_an_ubuntu_EC2_instance

resource "aws_instance" "gokul_ec2_instance" {
  ami              = "ami-03f4878755434977f"
  instance_type    = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name         = "mykey1"
 network_interface {
    network_interface_id = aws_network_interface.gokul_network_interface.id
    device_index         = 0
  }
  user_data = <<-EOF
  #!/bin/bash
     sudo apt-get update -y
     sudo apt-get update -y
     sudo apt-get install -y apache2
     sudo systemctl start apache2
     sudo systenctl enable apache2
  EOF
  tags = {
  Name = "Terraform hands-on"
  }
}

