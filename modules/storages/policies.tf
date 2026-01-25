data "aws_iam_policy_document" "storages" {
  for_each = var.storages

  dynamic "statement" {
    for_each = each.value.use_custom_kms_key == true ? [1] : []

    content {
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*"
      ]

      resources = [aws_kms_key.storages[each.key].arn]
    }
  }

  # adding redundant empty allow statement
  # in case all dynamic statements resolves to null
  statement {
    effect    = "Allow"
    actions   = ["none:null"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect  = "Allow"
    actions = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.aws_account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    condition {
      test     = "StringEquals"
      values   = [local.aws_account_id]
      variable = "kms:CallerAccount"
    }

    condition {
      test     = "StringEquals"
      values   = ["s3.${data.aws_region.current.region}.amazonaws.com"]
      variable = "kms:ViaService"
    }

    resources = ["*"]
  }
}
