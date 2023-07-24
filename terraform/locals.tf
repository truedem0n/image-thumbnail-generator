locals {
  source_s3_bucket_name = "source-s3-bucket-${local.account_id}"
  destination_s3_bucket_name = "destination-s3-bucket-${local.account_id}"
  sqs_queue_name = "s3-event-notification-queue-${local.account_id}"
  lambda_function_name = "generate-thumbnail-${local.account_id}"
}