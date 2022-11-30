output "ELB_ID" {
    value = aws_lb.Alb.id 
}
output "ELB_DNS" {
    value = aws_lb.Alb.dns_name
  
}
 output "TG_ARN" {
    value = aws_lb_target_group.target_group.arn
  
} 
output "ZONE_ID_ALB" {
    value = aws_lb.Alb.zone_id
}
