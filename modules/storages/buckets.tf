locals {
  storage_bucket_names = { for key, value in var.storages : key =>
    value.bucket_name == null ? lower(replace(join("-", compact([var.name_prefix, key])), "_", "-")) : value.bucket_name
  }
}

resource "aws_s3_bucket" "storages" {
  for_each      = { for key, value in var.storages : key => value if lookup(value, "create_bucket", null) == true }
  bucket        = local.storage_bucket_names[each.key]
  force_destroy = each.value.force_destroy
}

resource "aws_s3_bucket_versioning" "storages" {
  for_each = { for key, value in var.storages : key => value if lookup(value, "create_bucket", null) == true }
  bucket   = aws_s3_bucket.storages[each.key].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storages" {
  for_each = { for key, value in var.storages : key => value if lookup(value, "create_bucket", null) == true }
  bucket   = aws_s3_bucket.storages[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = each.value.use_custom_kms_key == true ? aws_kms_key.storages[each.key].arn : "alias/aws/s3"
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled       = each.value.use_custom_kms_key == true ? false : true
    blocked_encryption_types = each.value.use_custom_kms_key == true ? ["SSE-C"] : null
  }
}
