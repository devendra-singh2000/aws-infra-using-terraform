


//launch configuration
resource "aws_launch_configuration" "lc-java" {
  name_prefix     = "lc-java"
  image_id        = var.ASG_AMI
  instance_type   = var.ASG_INSTANCE_TYPE
  key_name        = var.KEY_NAME
  security_groups = var.EC2_SG
 
  lifecycle {
    create_before_destroy = true
  }
}

//auto scalling group
resource "aws_autoscaling_group" "asg-java" {
  name                      = "asg-java"
  vpc_zone_identifier       = var.VPC_ZONE
  launch_configuration      = aws_launch_configuration.lc-java.name
  min_size                  = var.ASG_MIN_INSTANCE
  max_size                  = var.ASG_MAX_INSTANCE
  desired_capacity          = var.ASG_DESIRED_CAPACITY
  health_check_grace_period = 200
  #health_check_type         = "ELB"
  target_group_arns = var.TG_GRP_ARN
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "WP-Instance"
    propagate_at_launch = true
  }
}

//scaling policy
