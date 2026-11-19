output "eks_cluster_sg_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "node_sg_id" {
  value = aws_security_group.eks_node_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}