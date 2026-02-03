resource "random_id" "main" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "main" {
  name                    = "one-env-laboratory-${random_id.main.hex}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id                = aws_secretsmanager_secret.main.id
  secret_string_wo         = jsonencode(local.keys)
  secret_string_wo_version = parseint(substr(sha256(jsonencode(local.keys)), 0, 8), 16)
}
