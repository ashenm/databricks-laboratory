data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "delegations" {
  dynamic "statement" {
    for_each = var.instance_profiles

    content {
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = [aws_iam_role.instance_profiles[statement.key].arn]
    }
  }
}
