resource "aws_sqs_queue" "webinstance_sqs" {
  name = "${var.username}-scaling"
}