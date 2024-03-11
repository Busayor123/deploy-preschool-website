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
  user_data                   = file("install_pre.sh")
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



# module "alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name    = "my-alb"
#   vpc_id  = module.vpc.vpc_id
#   subnets =  var.public_subnets

#   # Security Group
#   security_group_ingress_rules = {
#     all_http = {
#       from_port   = 80
#       to_port     = 80
#       ip_protocol = "tcp"
#       description = "HTTP web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#     # all_https = {
#     #   from_port   = 443
#     #   to_port     = 443
#     #   ip_protocol = "tcp"
#     #   description = "HTTPS web traffic"
#     #   cidr_ipv4   = "0.0.0.0/0"
#     # }
#   }
#   security_group_egress_rules = {
#     all = {
#       ip_protocol = "-1"
#       cidr_ipv4   = "10.0.0.0/17"
#     }
#   }

#   access_logs = {
#     bucket = "my-alb-logs"
#   }

#   # listeners = {
#   #   ex-http-https-redirect = {
#   #     port     = 80
#   #     protocol = "HTTP"
#   #     redirect = {
#   #       port        = "443"
#   #       protocol    = "HTTPS"
#   #       status_code = "HTTP_301"
#   #     }
#   #   }
#   #   ex-https = {
#   #     port            = 443
#   #     protocol        = "HTTPS"
#   #     certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

#   #     forward = {
#   #       target_group_key = "ex-instance"
#   #     }
#   #   }
#   # }

#   target_groups = {
#     ex-instance = {
#       name_prefix      = "h1"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"
#     }
#   }

#   tags = {
#     Environment = "Development"
#     Project     = "Example"
#   }
# }


# resource "aws_security_group" "alb_sg" {
#   name        = "ELb sg"
#   vpc_id      = module.vpc.vpc_id

#   // Ingress rules
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # // Add more ingress rules based on the variable
#   # dynamic "ingress" {
#   #   for_each = var.ingress_rules
#   #   content {
#   #     from_port   = ingress.value.from_port
#   #     to_port     = ingress.value.to_port
#   #     protocol    = ingress.value.protocol
#   #     cidr_blocks = ingress.value.cidr_blocks
#   #   }
#   }

#   // Egress rules
#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }

#   # // Add more egress rules based on the variable
#   # dynamic "egress" {
#   #   for_each = var.egress_rules
#   #   content {
#   #     from_port   = egress.value.from_port
#   #     to_port     = egress.value.to_port
#   #     protocol    = egress.value.protocol
#   #     cidr_blocks = egress.value.cidr_blocks
#   #   }




# resource "aws_lb" "test" {
#   name               = "ALB"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = var.public_subnets


#   # access_logs {
#   #   bucket  = aws_s3_bucket.lb_logs.id
#   #   prefix  = "test-lb"
#   #   enabled = true
#   # }

#   tags = {
#     Environment = "production"
#   }
# }

# resource "aws_lb" "front_end" {
#   # ...
# }

# resource "aws_lb_target_group" "front_end" {
#   # ...
# }

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   # ssl_policy        = "ELBSecurityPolicy-2016-08"
#   # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end.arn
#   }
# }

# resource "aws_lb_target_group" "TG" {
#   name     = "ALB TG"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id
# }
