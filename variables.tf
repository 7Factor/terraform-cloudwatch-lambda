variable lambda_filename {
  description = "The name of your lambda file."
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

variable cloudwatch_rule_event_pattern {
  description = "Heredoc style json blob that descibes a cloudwatch rule event pattern. Visit the AWS docs for more info."
}

variable lambda_environment_vars {
  type        = map(any)
  description = "A map of key/value pairs to pass to your lambda function."
}
