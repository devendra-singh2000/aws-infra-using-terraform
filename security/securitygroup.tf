resource "aws_security_group" "elb-securitygroup" {
  vpc_id      = var.VPC_ID
  name        = "ELB-SG"
  description = "security group for load balancer"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ELB-SG"
  }
}

resource "aws_security_group" "ec2-securitygroup" {
  vpc_id      = var.VPC_ID
  name        = "WP-SG"
  description = "security group for ec2 instances"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.elb-securitygroup.id]
    description = "via the security group of Load Balancer"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.elb-securitygroup.id]
    description = "via the security group of Load Balancer"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self = true
    description = "My Ip"
  }
  tags = {
    Name = "WP-SG"
  }
}

resource "aws_security_group" "rds-securitygroup" {
  vpc_id      = var.VPC_ID
  name        = "RDS-SG"
  description = "security group for RDS DB"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2-securitygroup.id]      #var.RDS_CIDR
    description = "only from ec2"
  }
  tags = {
    Name = "RDS-SG"
  }
}
