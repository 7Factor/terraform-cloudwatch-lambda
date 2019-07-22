variable lambda_s3_bucket {
  description = "The name of the S3 bucket that holds your lambda artifact."
}
variable lambda_s3_key {
  default = "The S3 key of your lambda artifact."
}

variable lambda_function_name {
  description = "The name of your lambda function"
}

variable lambda_handler {
  description = "The name of your lambda handler. Format is <FILE>.<HANDLER>"
}

variable lambda_runtime {
  description = "The runtime for you lambda function."
}

variable lambda_description {
  default     = ""
  description = "A description for your lambda. Defaults to empty string."
}

variable lambda_publish {
  default     = true
  description = "Controls whether to publish your lambda as a new version. Defaults to true."
}

variable lambda_environment_vars {
  type        = map(any)
  description = "A map of key/value pairs to pass to your lambda function."
}

variable cloudwatch_rule_event_pattern {
  description = "Heredoc style json blob that descibes a cloudwatch rule event pattern. Visit the AWS docs for more info."
}

variable tracing_config_mode {
  default     = "PassThrough"
  description = "The mode for xray tracing. Can either be PassThrough or Active. Defaults to Passthrough"
}
