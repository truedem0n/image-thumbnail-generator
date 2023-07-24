data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "sqs_policy_doc" {
  statement {
    sid       = "AllowSQSReceiveMessage"
    effect    = "Allow"
    resources = [aws_sqs_queue.queue.arn]
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
  }
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.source_s3_bucket_name}/*"]

    actions = [
      "s3:GetObject","s3:HeadObject", "s3:ListBucket"
    ]
  }
  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.destination_s3_bucket_name}/*"]

    actions = [
      "s3:PutObject"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
    name   = "lambda_policy"
    policy = data.aws_iam_policy_document.sqs_policy_doc.json
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
    name       = "lambda_policy_attachment"
    roles      = [aws_iam_role.iam_for_lambda.name]
    policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "../lambda/"
  output_path = "lambda_function_payload.zip"
}

# resource "aws_lambda_layer_version" "lambda_layer" {
#   filename   = "../lambda/layer.zip"
#   layer_name = "pilLayer"

#   compatible_runtimes = ["python3.9"]
# }

resource "aws_lambda_function" "generate_thumbnail" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = local.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  layers = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p310-Pillow:2"]

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
      source_bucket = module.source_s3_bucket.s3_bucket_id
      destination_bucket = module.destination_s3_bucket.s3_bucket_id
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.generate_thumbnail.arn
}