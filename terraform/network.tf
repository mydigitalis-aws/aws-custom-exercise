# create an IGW (Internet Gateway)
# It enables your vpc to connect to the internet
resource "aws_internet_gateway" "digitalis-igw" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"

    tags = {
        Name = "digitalis-igw"
        Environment="Dev"
    }
}



# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.digitalis-igw]
}

# NAT
resource "aws_nat_gateway" "digitalis-nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.digitalis-subnet-public-1.id

  tags = {
    Name        = "digitalis-nat"
    Environment = "Dev"
  }
}


# create a custom route table for public subnets
# public subnets can reach to the internet buy using this
resource "aws_route_table" "digitalis-public-crt" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"   
    tags = {
        Name = "digitalis-public-crt"
    }
}

resource "aws_route_table" "digitalis-private-crt" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"   
    tags = {
        Name = "digitalis-private-crt"
    }
}

resource "aws_route_table" "digitalis-workload-crt" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"   
    tags = {
        Name = "digitalis-workload-crt"
    }
}



#Route definition from public subnet associated route table to internet gateway
resource "aws_route" "vpc-rtb-public-igw" {
  route_table_id            = aws_route_table.digitalis-public-crt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.digitalis-igw.id
}

#Route definition from private subnet associated route table to NAT gateway
resource "aws_route" "vpc-rtb-private-igw" {
  route_table_id            = aws_route_table.digitalis-private-crt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_nat_gateway.digitalis-nat.id
}

#Route definition from workload subnet associated route table to NAT gateway
resource "aws_route" "vpc-rtb-workload-igw" {
  route_table_id            = aws_route_table.digitalis-workload-crt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_nat_gateway.digitalis-nat.id
}



# route table association for the public subnets
resource "aws_route_table_association" "digitalis-crta-public-subnet-1" {
    subnet_id = "${aws_subnet.digitalis-subnet-public-1.id}"
    route_table_id = "${aws_route_table.digitalis-public-crt.id}"
}


# route table association for the private subnets
resource "aws_route_table_association" "digitalis-crta-private-subnet-1" {
    subnet_id = "${aws_subnet.digitalis-subnet-private-1.id}"
    route_table_id = "${aws_route_table.digitalis-private-crt.id}"
}


# route table association for the public subnets
resource "aws_route_table_association" "digitalis-crta-workload-subnet-1" {
    subnet_id = "${aws_subnet.digitalis-subnet-workload-1.id}"
    route_table_id = "${aws_route_table.digitalis-workload-crt.id}"
}


resource "aws_network_acl" "digitalis-private-subnet-networkACL" {
  vpc_id = aws_vpc.digitalis-vpc.id
  subnet_ids = [aws_subnet.digitalis-subnet-private-1.id]
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.20.0/24"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.20.0/24"
    from_port  = 3389
    to_port    = 3389
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.20.0/24"
    from_port  = 443
    to_port    = 443
  }
   ingress {

    protocol   = "-1"
    rule_no    = 400
    action     = "deny"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    
    protocol   = "-1"
    rule_no    = 500
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
 
  egress {
    
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 22
    to_port    = 22
  }
 egress {
    
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 3389
    to_port    = 3389
  }

  egress {
    
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 443
    to_port    = 443
  }

   egress {

    protocol   = "-1"
    rule_no    = 400
    action     = "deny"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }
  egress {
    
    protocol   = "-1"
    rule_no    = 500
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "private-subnet-networkACL"
  }
}

resource "aws_network_acl" "digitalis-workload-subnet-networkACL" {
  vpc_id = aws_vpc.digitalis-vpc.id
  subnet_ids = [aws_subnet.digitalis-subnet-workload-1.id]
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 3389
    to_port    = 3389
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 443
    to_port    = 443
  }
   ingress {

    protocol   = "-1"
    rule_no    = 400
    action     = "deny"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    
    protocol   = "-1"
    rule_no    = 500
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
 
  egress {
    
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }
 egress {
    
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 3389
    to_port    = 3389
  }

  egress {
    
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 443
    to_port    = 443
  }

   egress {

    protocol   = "-1"
    rule_no    = 400
    action     = "deny"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }
  egress {
    
    protocol   = "-1"
    rule_no    = 500
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "workload-subnet-networkACL"
  }
}

# security group for public subnet
resource "aws_security_group" "public-sg" {
    name="HTTPS and SSH"
    vpc_id = "${aws_vpc.digitalis-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    //If you do not add this rule, you can not reach the NGIX
    #ingress {
    #    from_port = 80
    #    to_port = 80
    #    protocol = "tcp"
    #    cidr_blocks = ["0.0.0.0/0"]
    #}

    tags ={
        Name = "public-https-ssh-allowed"
    }
}

resource "aws_security_group" "ssh_bastion_public_subnet_sg" {
  depends_on=[aws_subnet.digitalis-subnet-public-1]
  name        = "ssh_public_subnet_bastion_sg"
  vpc_id      =  aws_vpc.digitalis-vpc.id

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_public_subnet_bastion"
    Environment = "Dev"
  }
}


 resource "aws_security_group" "ssh_bastion_workload_subnet_sg" {
    depends_on=[aws_subnet.digitalis-subnet-workload-1]
  name        = "ssh_workload_subnet_bastion_sg"
  description = "allow ssh bastion inbound traffic from public subnet"
  vpc_id      =  aws_vpc.digitalis-vpc.id




 ingress {
    description = "Bastion access to workload ec2 instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups=[aws_security_group.ssh_bastion_public_subnet_sg.id]
 
 }



 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  tags = {
    Name = "workload ec2 access bastion"
  }
}


 resource "aws_security_group" "ssh_bastion_private_subnet_sg" {
    depends_on=[aws_subnet.digitalis-subnet-private-1]
  name        = "ssh_private_subnet_bastion_sg"
  description = "allow ssh bositon inbound traffic to private ec2 instance from workload"
  vpc_id      =  aws_vpc.digitalis-vpc.id




 ingress {
    description = "Bastion access to private ec2 instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups=[aws_security_group.ssh_bastion_workload_subnet_sg.id]
 
 }



 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  tags = {
    Name = "private ec2 access bastion"
  }
}


# security group for workload subnet, allow traffic from public subnet to ec2 in workload subnet
resource "aws_security_group" "workload-sg" {
    name="workload-sg"
    vpc_id = "${aws_vpc.digitalis-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    #ALlow traffic from public subnet CIDR to workload subnet on port 22 (ssh)
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.1.0/24"]
    }
    
    #ALlow traffic from public subnet CIDR to workload subnet on port 443 (https) optionally 
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

   tags ={
        Name = "workload-https-ssh-allowed"
    }
}

# security group for private subnet, allow traffic from workload subnet to ec2 in private subnet
resource "aws_security_group" "private-sg" {
    name="workload-to-private-sg"
    vpc_id = "${aws_vpc.digitalis-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    #ALlow traffic from workload subnet CIDR to private subnet on port 22 (ssh)
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.20.0/24"]
    }
    
    #ALlow traffic from workload subnet CIDR to private subnet on port 443 (https) optionally 
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.20.0/24"]
  }

   tags ={
        Name = "private-https-ssh-allowed"
    }
}


