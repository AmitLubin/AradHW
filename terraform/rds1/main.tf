provider "aws" {
    region = "il-central-1"
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "imtech/amit"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "amit"
    password = "1234"
  })
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/amit/db/db-host"
  type  = "String"
  value = "database-1.c3mggk2emfx1.il-central-1.rds.amazonaws.com"
  overwrite = true

  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
  }

}