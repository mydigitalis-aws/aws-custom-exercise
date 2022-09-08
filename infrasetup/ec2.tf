
#keypair for public zone bastion
resource "tls_private_key" "rsa-public-zone"{
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "public-zone-key" {
    key_name = "public-zone-key"
    public_key = tls_private_key.rsa-public-zone.public_key_openssh
}

resource "local_sensitive_file" "TF_key" {
    
    content   = tls_private_key.rsa-public-zone.private_key_pem
    filename = "tfkey.pem"
    file_permission = "0400"
}

#keypair for workload zone ec2
resource "tls_private_key" "rsa-workload-zone"{
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "workload-zone-key" {
    key_name = "workload-zone-key"
    public_key = tls_private_key.rsa-workload-zone.public_key_openssh
}

resource "local_sensitive_file" "TF_key1" {
    content  = tls_private_key.rsa-public-zone.private_key_pem
    filename = "tfkey1.pem"
    file_permission = "0400"
}

#keypair for workload zone bastion host
resource "tls_private_key" "rsa-workload-zone-bastion"{
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "workload-zone-key-bastion" {
    key_name = "workload-zone-key-bastion"
    public_key = tls_private_key.rsa-workload-zone-bastion.public_key_openssh
}

resource "local_sensitive_file" "workloadbastionkey1" {
    content = tls_private_key.rsa-workload-zone-bastion.private_key_pem

    filename = "workloadbastionkey1.pem"
    file_permission = "0400"
}

#keypair for private zone ec2
resource "tls_private_key" "rsa-private-zone"{
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "private-zone-key" {
    key_name = "private-zone-key"
    public_key = tls_private_key.rsa-private-zone.public_key_openssh
}

resource "local_sensitive_file" "TF_key2" {
    content  = tls_private_key.rsa-private-zone.private_key_pem
    
    filename = "tfkey2.pem"
    file_permission = "0400"
}


resource "aws_instance" "digitalis-workload" {
    
    #ami = "${lookup(var.AMI, var.AWS_REGION)}"
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    
    # the Public SSH key
    key_name = "${aws_key_pair.workload-zone-key.id}"

    # VPC
    subnet_id = "${aws_subnet.digitalis-subnet-workload-1.id}"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.workload-sg.id}"]   
    associate_public_ip_address = false
    connection {
        type = "ssh"
        user = "${var.EC2_USER}"
        private_key= local_file.TF_key1.filename
    }

     tags = {
      Name = "digitalis workload ec2"
  }
}

resource "aws_ebs_volume" "workload_ebs" {
     availability_zone = var.AWS_AVAILABILITY_ZONE
     size             = 40
      tags = {
      Name = "digitalis workload ebs"
  }
}

resource "aws_volume_attachment" "ebs_workload_att" {
     device_name = "/dev/sdh"
     volume_id   = aws_ebs_volume.workload_ebs.id
     instance_id = aws_instance.digitalis-workload.id
}

resource "aws_instance" "digitalis-private" {
    
    #ami = "${lookup(var.AMI, var.AWS_REGION)}"
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    
    # the Public SSH key
    key_name = "${aws_key_pair.private-zone-key.id}"

    # VPC
    subnet_id = "${aws_subnet.digitalis-subnet-private-1.id}"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]   
    associate_public_ip_address = false
    connection {
        type = "ssh"
        user = "${var.EC2_USER}"
        #private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
        private_key= local_file.TF_key2.filename
    }
     tags = {
      Name = "digitalis private ec2"
  }
}

resource "aws_ebs_volume" "private_ebs" {
     availability_zone = var.AWS_AVAILABILITY_ZONE
     size             = 40
      tags = {
      Name = "digitalis private ebs"
  }
}

resource "aws_volume_attachment" "ebs_private_att" {
     device_name = "/dev/sdg"
     volume_id   = aws_ebs_volume.private_ebs.id
     instance_id = aws_instance.digitalis-private.id
   
}

# bastion host ec2 instance first in public subnet, then in workload subnet
resource "aws_instance" "bastion_host_public_subnet" {
  depends_on = [
    aws_security_group.ssh_bastion_public_subnet_sg,
  ]
  #ami = "ami-052efd3df9dad4825"
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.public-zone-key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_bastion_public_subnet_sg.id]
  subnet_id     = aws_subnet.digitalis-subnet-public-1.id
  associate_public_ip_address = true
  tags = {
      Name = "public subnet bastion host"
  }
  #provisioner "file" {
  #  source      = "tfkey.pem"
  #  destination = "/home/ec2-user/tfkey.pem"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key= local_sensitive_file.TF_key.filename
    #private_key= file("{path.module}/tfkey.pem")
    host     = aws_instance.bastion_host_public_subnet.public_ip
    }
#}
}

resource "aws_instance" "bastion_host_workload_subnet" {
  depends_on = [
    aws_security_group.ssh_bastion_workload_subnet_sg,
  ]
  #ami = "ami-052efd3df9dad4825"
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.workload-zone-key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_bastion_workload_subnet_sg.id]
  subnet_id     = aws_subnet.digitalis-subnet-workload-1.id
  tags = {
      Name = "workload subnet bastion host"
  }

 #  provisioner "file" {
 #   source      = "tfkey1.pem"
 #   destination = "/home/ec2-user/tfkey1.pem"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = local_sensitive_file.TF_key1.filename
    host     = aws_instance.bastion_host_workload_subnet.public_ip
    }
 # }
}


