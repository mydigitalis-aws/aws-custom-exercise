
resource "aws_vpc" "digitalis-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default"
    
    tags = {
        Name = "digitalis-vpc"
        Environment = "Dev"
    }
}

resource "aws_subnet" "digitalis-subnet-public-1" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet where deployed ec2 instances get a public IP
    #availability_zone = "us-east-1a"
    availability_zone = "${var.AWS_AVAILABILITY_ZONE}"

    tags = {
        Name = "digitalis-subnet-public-1"
        Environment = "Dev"
    }
}

resource "aws_subnet" "digitalis-subnet-private-1" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"
    cidr_block = "10.0.10.0/24"
    map_public_ip_on_launch = "false" //keeps this private so that ec2 instances deployed here get a private IP
    #availability_zone = "us-east-1a"
    availability_zone = "${var.AWS_AVAILABILITY_ZONE}"

    tags = {
        Name = "digitalist-subnet-private-1"
        Environment = "Dev"
    }
}

resource "aws_subnet" "digitalis-subnet-workload-1" {
    vpc_id = "${aws_vpc.digitalis-vpc.id}"
    cidr_block = "10.0.20.0/24"
    map_public_ip_on_launch = "false" //keeps this private so that ec2 instances deployed here get a private IP
    #availability_zone = "us-east-1a"
    availability_zone = "${var.AWS_AVAILABILITY_ZONE}"

    tags = {
        Name = "digitalis-subnet-workload-1"
    }
}

variable "subnet_ids" {
  type    = list(string)
  default = ["aws_subnet.digitalis-subnet-workload-1.id","aws_subnet.digitalis-subnet-private-1.id"]
}