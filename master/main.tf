data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

module "vpc" {
  source         = "../vpc/"
  vpc_cidr_block = var.vpc_cidr_block
}

module "security" {
  depends_on = [     module.vpc
  ]
  source = "../security/"
  #vpcid = module.vpc.Vpcid
  VPC_ID = module.vpc.Vpcid
}


module "subnet" {
  source         = "../subnet/"
  vpc_cidr_block = var.vpc_cidr_block
  vpcid = module.vpc.Vpcid
}

module "rds" {
  source = "../rds/"
  //depends_on = [
  //  module.elb
  //]
  RDS_IDENTIFIER              = var.RDS_IDENTIFIER              //RDS IDENTIFIER
  RDS_DB_NAME                 = var.RDS_DB_NAME                 //DB INSTANCE INITIAL DATABASE
  RDS_STORAGE_TYPE            = var.RDS_STORAGE_TYPE            //STORAGE TYPE - 
  RDS_INSTANCE_CLASS          = var.RDS_INSTANCE_CLASS          //INSTANCE CLASS
  RDS_ENGINE                  = var.RDS_ENGINE                  //ENGINE NAME
  RDS_ENGINE_VERSION          = var.RDS_ENGINE_VERSION          //ENGINE VERSION
  RDS_BACKUP_RETENTION_PERIOD = var.RDS_BACKUP_RETENTION_PERIOD //RETENTION PERIOD FOR BACKUP
  RDS_USERNAME                = var.RDS_USERNAME                //RDS USERNAME
  RDS_PASSWORD                = var.RDS_PASSWORD                // RDS PASSWORD
  RDS_ALLOCATED_STORAGE       = var.RDS_ALLOCATED_STORAGE       //ALLOCATED STORAGE
  RDS_MULTIAZ                 = var.RDS_MULTIAZ                 // MULTI AZ - RDS

  RDS_SG             = [module.security.RDS_SG]
  PRIVATE_SUBNET_GRP = [module.subnet.PRIVATE_DATABASE_ID_1, module.subnet.PRIVATE_DATABASE_ID_2]
}

module "elb" {

  source           = "../ELB/"
  ELB_NAME         = var.ELB_NAME                                                   //LOAD BALANCER NAME
  LB_TYPE          = var.LB_TYPE                                                    //LOAD BALACER TYPE
  PUBLIC_SUBNET_ID = [module.subnet.PUBLIC_SUBNET_ID_1, module.subnet.PUBLIC_SUBNET_ID_2] // ASSOCIATED PUBLIC SUBNET
  SG               = [module.security.ELB_SG]                                       //SECURITY GROUP FOR LOAD BALANCER
  TG_VPC           = module.vpc.Vpcid                                              // ASSOCIATED VPC FOR  LOAD BALANCER
}

module "asg" {
  source = "../asg/"
  depends_on = [
    module.elb
  ]
  VPC_ZONE             = [module.subnet.PUBLIC_SUBNET_ID_1, module.subnet.PUBLIC_SUBNET_ID_2] //VPC PUBLIC SUBNET TO BE ASSOCIATED IN ASG FOR HA
  ASG_AMI              = data.aws_ami.ubuntu.id               //PRECONFIGURED AMI FOR NGINX UBUNTU
  ASG_INSTANCE_TYPE    = var.ASG_INSTANCE_TYPE       //INSTANCE TYPE EC2 T3A.SMALL
  ASG_MAX_INSTANCE     = var.ASG_MAX_INSTANCE          //MAXIMUM INSTANCES VIA ASG
  ASG_MIN_INSTANCE     = var.ASG_MIN_INSTANCE             //MINIMUM INSTANCES VIA ASG
  ASG_DESIRED_CAPACITY = var.ASG_DESIRED_CAPACITY            //DESIRED CAPACITY OF INSTANCES
  KEY_NAME             = "myKey"

  
  EC2_SG     = [module.security.EC2_SG] //SECURITY GROUP FOR INSTANCES VIA ASG
  TG_GRP_ARN = [module.elb.TG_ARN]      //ASSOCIATION OF TARGET GROUP 
}
