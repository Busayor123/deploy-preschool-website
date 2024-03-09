module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "jenkins-vpc"
  cidr                 = var.vpc_cidr
  public_subnets       = var.public_subnets
  enable_dns_hostnames = true
  azs                  = data.aws_availability_zones.AZS.names

  tags = {
    Name        = "Jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}



module "Jenkins_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Jenkins sg"
  description = "Security group for Jenkins"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}


module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-server"

  instance_type               = "t2.micro"
  key_name                    = "key_pair"
  monitoring                  = true
  vpc_security_group_ids      = [module.Jenkins_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("installme.sh")
  availability_zone           = data.aws_availability_zones.AZS.names[0]


  tags = {
    Name        = "Jenkins-server"
    Terraform   = "true"
    Environment = "dev"
  }

}
output "public_ip" {
  value = module.ec2_instance.public_ip
}
