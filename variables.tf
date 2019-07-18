variable lambda_function_name {
  description = "The name of your lambda function"
}

variable lambda_handler {
  description = "The name of your lambda handler. Format is <FILE>.<HANDLER>"
}

variable "webhook_url" {
  description = "The webhook_url from your Slack app."
}
