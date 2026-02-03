resource "aws_kms_key" "storages" {
  for_each                           = var.storages
  key_usage                          = "ENCRYPT_DECRYPT"
  bypass_policy_lockout_safety_check = false
  enable_key_rotation                = true
}

resource "aws_kms_key_policy" "storages" {
  for_each = var.storages
  key_id   = aws_kms_key.storages[each.key].key_id
  policy   = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "storages" {
  for_each      = var.storages
  target_key_id = aws_kms_key.storages[each.key].key_id
  name          = "alias/${upper(replace(join("-", compact([var.name_prefix, each.key])), "_", "-"))}"
}
