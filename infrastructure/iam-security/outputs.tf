output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "lb_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "router_ecs_sg_id" {
  value = aws_security_group.router_ecs_sg.id
}

output "lb_sg_router_id" {
  value = aws_security_group.lb_sg_router.id
}