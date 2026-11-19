resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project-name}-db-subnet-group"
  subnet_ids = var.private_subnets_ids

  tags = {
    Name         = "${var.project-name}-db-subnet-group"
    project-name = var.project-name
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.project-name}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period    = var.backup_retention_period
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true
  apply_immediately          = true
  deletion_protection        = false

  tags = {
    Name         = "${var.project-name}-postgres"
    project-name = var.project-name
  }
}

data "http" "rds_ca_bundle" {
  url = "https://truststore.pki.rds.amazonaws.com/eu-west-2/eu-west-2-bundle.pem"
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project-name}-redis-subnets"
  subnet_ids = var.private_subnets_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project-name}-redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
  security_group_ids   = [var.redis_sg_id]
  subnet_group_name    = aws_elasticache_subnet_group.redis.name

  tags = {
    Name         = "${var.project-name}-redis"
    project-name = var.project-name
  }
}

resource "random_password" "db" {
  length  = 24
  special = false
}

resource "random_id" "infisical_encryption_key" {
  byte_length = 16
}

resource "random_id" "infisical_auth_secret" {
  byte_length = 32
}

resource "aws_secretsmanager_secret" "infisical_app" {
  name                    = "infisical/app"
  recovery_window_in_days = 0

  tags = {
    Name         = "infisical/app"
    project-name = var.project-name
  }
}

resource "aws_secretsmanager_secret_version" "infisical_app" {
  secret_id = aws_secretsmanager_secret.infisical_app.id
  secret_string = jsonencode({
    username          = var.db_username
    password          = random_password.db.result
    ENCRYPTION_KEY    = random_id.infisical_encryption_key.hex
    AUTH_SECRET       = random_id.infisical_auth_secret.b64_std
    DB_CONNECTION_URI = "postgresql://${var.db_username}:${random_password.db.result}@${aws_db_instance.postgres.address}:5432/${var.db_name}"
    REDIS_URL         = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379"
    DB_ROOT_CERT      = base64encode(data.http.rds_ca_bundle.response_body)
  })
}