module "source_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.source_s3_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

resource "aws_s3_bucket_notification" "source_bucket_notification" {
  bucket = module.source_s3_bucket.s3_bucket_id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    # filter_suffix = ""
  }
}

module "destination_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.destination_s3_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}