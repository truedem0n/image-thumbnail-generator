data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:${local.sqs_queue_name}"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.source_s3_bucket.s3_bucket_arn]
    }
  }
}

resource "aws_sqs_queue" "queue" {
  name   = local.sqs_queue_name
  policy = data.aws_iam_policy_document.queue.json
}


