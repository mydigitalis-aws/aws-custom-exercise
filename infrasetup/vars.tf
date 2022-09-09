variable "AWS_REGION" {
  type   = string
 #default = "us-east-1"
 #default = "eu-central-1"
}

variable "AWS_AVAILABILITY_ZONE" {
  type    = string
  #default = "us-east-1a"
  #default = "eu-central-1a"
}
variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
  default     = "USEast1A_dev1_"
}

variable "public_path" {
    default  = "C:\\digitalis\\data\\key"
}

variable "PRIVATE_KEY_PATH" {
  default = "rsa-public-zone"
}

variable "PUBLIC_KEY_PATH" {
  default = "public-zone-key.pub"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  
}
variable "EC2_USER" {
  default = "ubuntu"
}

variable "bastion_instance_types" {
  type        = list(string)
  description = "Bastion instance types used for spot instances."
  default     = ["t4g.nano", "t4g.micro", "t4g.small"]
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key used to connect to the bastion host"
  default     = "bkey1"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to be used for bastion host. If not provided, it will default to latest amazon linux 2 image."
  default     = ""
}

variable "hosted_zone_id" {
  type        = string
  description = "Hosted zone id where A record will be added for bastion host/s."
  default     = ""
}

variable "desired_capacity" {
  type        = number
  description = "Auto Scalling Group value for desired capacity of bastion hosts."
  default     = 1
}

variable "on_demand_base_capacity" {
  type        = number
  description = "Auto Scalling Group value for desired capacity for instance lifecycle type on-demand of bastion hosts."
  default     = 0
}

variable "max_size" {
  type        = number
  description = "Auto Scalling Group value for maximum capacity of bastion hosts."
  default     = 1
}

variable "min_size" {
  type        = number
  description = "Auto Scalling Group value for minimum capacity of bastion hosts."
  default     = 1
}

variable "ssh_port" {
  description = "SSH port used to access a bastion host."
  default     = 22
}

variable "AMI" {
  type = map(string)

  default =  {
    eu-west-2 = "ami-03dea29b0216a1e03"
    us-east-1 = "ami-0c2a1acae6667e438"
  }
}