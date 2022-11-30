resource "aws_lb" "Alb" {
  name            = var.ELB_NAME
  internal = false
  load_balancer_type = var.LB_TYPE  
  subnets         = var.PUBLIC_SUBNET_ID
  security_groups = var.SG
  

  tags = {
    Name = "java-elb"
  }
}



resource "aws_lb_target_group" "target_group" {
  name        = "tf-lb-tg"
  target_type = "instance"
  health_check {
    matcher = "200,404"
    interval = "10"
  }
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.TG_VPC
}
# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   #target_id        = aws_instance.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = aws_instance.id
#   port             = 80
# }